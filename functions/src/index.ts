import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

// export const sendToTopic = functions.firestore
//   .document('puppies/{puppyId}')
//   .onCreate(async snapshot => {
//     const puppy = snapshot.data();
//     const payload: admin.messaging.MessagingPayload = {
//       notification: {
//         title: 'New Puppy!',
//         body: `${puppy.name} is ready for adoption`,
//         icon: '',
//         click_action: 'FLUTTER_NOTIFICATION_CLICK'
//       }
//     };

//     return fcm.sendToTopic('puppies', payload);
//   });

export const sendToDevice = functions.firestore
  .document('tasks/{taskId}/applicants/{applicantId}')
  .onCreate(async (snapshot, context) => {
    console.log("taskID:", context.params.taskId);
    console.log("appId:", context.params.applicantId);
    const userIdQuery = await db.collection('tasks').doc(context.params.taskId).get();
    const userId = userIdQuery.data()['userId'];
    const applicantId = snapshot.id;
    console.log("start find token: ", userId);
    const querySnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('tokens')
      .get();
    const nameQuery = await db
      .collection('users')
      .doc(applicantId)
      .get();
    console.log("finish find token");
    const tokens = querySnapshot.docs.map(snap => snap.id);

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'New Person Comes',
        body: `Your request got a response from ${nameQuery.data()['name']}`,
        // icon: '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    return fcm.sendToDevice(tokens, payload);
  });

  const gmailEmail = functions.config().gmail.email;
  const gmailPassword = functions.config().gmail.password;
  const mailTransport = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: gmailEmail,
      pass: gmailPassword,
    },
  });
  
  const APP_NAME = 'UWanted';
  
  export const sendNotifyEmail = functions.firestore
  .document('tasks/{taskId}/applicants/{applicantId}')
  .onCreate(async (snapshot, context) => {
    const userIdQuery = await db.collection('tasks').doc(context.params.taskId).get();
    const userId = userIdQuery.data()['userId'];
    const applicantId = snapshot.id;
    const nameQuery = await db
      .collection('users')
      .doc(applicantId)
      .get();
    const nameQuery2 = await db
      .collection('users')
      .doc(userId)
      .get();
    const email = await findUserEmail(userId); // The email of the user.
    const appName = await nameQuery.data()['name']; // The display name of the user.
    const userName = await nameQuery2.data()['name'];
    return sendHelper(email, appName, userName);
  });

async function findUserEmail(uid){
  console.log('Finding User Email')
  return new Promise((resolve, reject) => {
    admin.auth().getUser(uid)
      .then(userRecord => {
        console.log("JSON: ", userRecord.toJSON())
        console.log("email: ", userRecord.toJSON()['email'])
        resolve(userRecord.toJSON()['email']) // WARNING! Filter the json first, it contains password hash!
      })
      .catch(error => {
        console.error('Error fetching user data:', error)
        reject({status: 'error', code: 500, error})
      })
  })
}

  // Sends a noti email to the given user.
async function sendHelper(email, appName, userName) {
  console.log("Sending User Msg")
  const mailOptions = {
    from: `${APP_NAME} <noreply@firebase.com>`,
    to: email,
    subject: "",
    text: "",
  };

  // The user subscribed to the newsletter.
  mailOptions.subject = `Your post just got one response!`;
  mailOptions.text = `Hey ${userName || ''}! Your post just got one response from ${appName || ''}`;
  await mailTransport.sendMail(mailOptions);
  console.log('New notification email sent to:', email);
  return null;
}

// [START sendWelcomeEmail]
/**
 * Sends a welcome email to new user.
 */
// [START onCreateTrigger]
exports.sendWelcomeEmail = functions.firestore
.document('users/{userId}')
.onCreate(async (snapshot, context) => {
  // [END onCreateTrigger]
    // [START eventAttributes]
    const userId = snapshot.id;
    const email = await findUserEmail(userId); // The email of the user.
    // [END eventAttributes]
  
    return sendWelcomeEmail(email);
  });
  // [END sendWelcomeEmail]
  
  // [START sendByeEmail]
  /**
   * Send an account deleted email confirmation to users who delete their accounts.
   */
  // [START onDeleteTrigger]
  exports.sendByeEmail = functions.auth.user().onDelete((user) => {
  // [END onDeleteTrigger]
    const email = user.email;
    const displayName = user.displayName;
  
    return sendGoodbyeEmail(email, displayName);
  });
  // [END sendByeEmail]
  
  // Sends a welcome email to the given user.
  async function sendWelcomeEmail(email) {
    const mailOptions = {
      from: `${APP_NAME} <noreply@firebase.com>`,
      to: email,
      subject: "",
      text: "",
    };
  
    // The user subscribed to the newsletter.
    mailOptions.subject = `Welcome to ${APP_NAME}!`;
    mailOptions.text = `Hey there! Welcome to ${APP_NAME}. We hope you will enjoy our service.`;
    await mailTransport.sendMail(mailOptions);
    console.log('New welcome email sent to:', email);
    return null;
  }
  
  // Sends a goodbye email to the given user.
  async function sendGoodbyeEmail(email, displayName) {
    const mailOptions = {
      from: `${APP_NAME} <noreply@firebase.com>`,
      to: email,
      subject: "",
      text: "",
    };
  
    // The user unsubscribed to the newsletter.
    mailOptions.subject = `Bye!`;
    mailOptions.text = `Hey ${displayName || ''}!, We confirm that we have deleted your ${APP_NAME} account.`;
    await mailTransport.sendMail(mailOptions);
    console.log('Account deletion confirmation email sent to:', email);
    return null;
  }