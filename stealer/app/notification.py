from firebase_admin import messaging

def send_firebase_notification(token, type):
    """
    Sends a notification to an FCM token.

    :param token: The FCM registration token for a device
    :param title: Title of the notification
    :param body: Body of the notification
    """
    # Create the message to be sent
    message = messaging.Message(
        data={
            "type": type
            },
        token=token,
    )

    # Send the notification
    try:
        response = messaging.send(message)
        print('Successfully sent message:', response)
    except Exception as e:
        print('Error sending message:', e)
