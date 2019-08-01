import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
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
    const userId = snapshot.id;
    console.log("start find token: ", userId);
    const querySnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('tokens')
      .get();
    const nameQuery = await db
      .collection('users')
      .doc(userId)
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