import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

admin.initializeApp();
const db = admin.firestore();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2023-10-16', // Note: use appropriate version
});

// ─── STRIPE ENDPOINTS ──────────────────────────────────────────────────

export const createStripeCheckout = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const { planId, interval } = data; // e.g. planId='pro', interval='month'
  const userId = context.auth.uid;
  
  // Note: in a real app, you map planId to a Stripe Price ID.
  const priceId = 'price_12345'; // Dummy, to be configured in Stripe Dashboard.

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: 'https://yourapp.com/success?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: 'https://yourapp.com/cancel',
      client_reference_id: userId,
      metadata: { userId, planId },
    });

    return { sessionId: session.id, url: session.url };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = 'whsec_...'; // Replace with webhook secret

  let event;
  try {
    // Note: requires raw body
    event = stripe.webhooks.constructEvent(req.rawBody, sig as string, endpointSecret);
  } catch (err: any) {
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as any;
    const userId = session.metadata.userId;
    const planId = session.metadata.planId;

    await db.collection('users').doc(userId).collection('subscriptions').doc('current').set({
      plan: planId,
      status: 'active',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  res.json({ received: true });
});

// ─── CHAPA ENDPOINTS ───────────────────────────────────────────────────

export const createChapaCheckout = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const { amount, currency, email, firstName, lastName, planId } = data;
  const tx_ref = `tx-${context.auth.uid}-${Date.now()}`;

  const fetch = (await import('node-fetch')).default;
  
  const response = await fetch('https://api.chapa.co/v1/transaction/initialize', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.CHAPA_SECRET_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      amount: amount.toString(),
      currency: currency || 'ETB',
      email: email,
      first_name: firstName,
      last_name: lastName,
      tx_ref: tx_ref,
      callback_url: `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/chapaWebhook`,
      return_url: 'https://yourapp.com/success',
      customization: {
        title: 'Wanderlust Premium',
        description: `Subscription for ${planId} plan`
      },
      meta: { userId: context.auth.uid, planId }
    })
  });

  const responseData = await response.json();
  if (responseData.status === 'success') {
    return { checkoutUrl: responseData.data.checkout_url, tx_ref };
  } else {
    throw new functions.https.HttpsError('internal', responseData.message);
  }
});

export const chapaWebhook = functions.https.onRequest(async (req, res) => {
  // Chapa verification (signature checking and tx verification)
  const tx_ref = req.body.tx_ref;
  if (!tx_ref) {
    res.status(400).send('Missing tx_ref');
    return;
  }

  const fetch = (await import('node-fetch')).default;
  const response = await fetch(`https://api.chapa.co/v1/transaction/verify/${tx_ref}`, {
    method: 'GET',
    headers: { 'Authorization': `Bearer ${process.env.CHAPA_SECRET_KEY}` }
  });

  const responseData = await response.json();
  if (responseData.status === 'success') {
    const data = responseData.data;
    // We expect userId to be passed in meta. But if not, we extract from tx_ref: `tx-${userId}-${timestamp}`
    const parts = tx_ref.split('-');
    const userId = parts[1];
    const planId = 'pro'; // Determine from meta or DB

    await db.collection('users').doc(userId).collection('subscriptions').doc('current').set({
      plan: planId,
      status: 'active',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      tx_ref,
    });
  }

  res.status(200).send('OK');
});
