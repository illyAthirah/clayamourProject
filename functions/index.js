/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

const stripeSecret = defineSecret("STRIPE_SECRET_KEY");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.createPaymentIntent = onRequest(
    {secrets: [stripeSecret]},
    async (request, response) => {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");

  if (request.method === "OPTIONS") {
    response.status(204).send("");
    return;
  }

  if (request.method !== "POST") {
    response.status(405).send("Method not allowed.");
    return;
  }

  if (!stripeSecret.value()) {
    logger.error("Missing STRIPE_SECRET_KEY secret.");
    response.status(500).send("Stripe is not configured.");
    return;
  }

  try {
    const stripe = require("stripe")(stripeSecret.value());
    const {amount, currency} = request.body || {};
    if (!amount || !currency) {
      response.status(400).send("Missing amount or currency.");
      return;
    }

    const intent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: {enabled: true},
    });

    response.status(200).json({clientSecret: intent.client_secret});
  } catch (error) {
    logger.error("Stripe error", error);
    response.status(500).send("Failed to create payment intent.");
  }
});
