from django.contrib import admin
from .models import UserDevice, UserNotification, UserNotificationType, UserData
from .notification import send_firebase_notification

class UserNotificationAdmin(admin.ModelAdmin):
    list_display = ['message', 'device']


    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)  
        
        # Fetch the device token
        device_token = obj.device.device_token
        
        # Send Firebase notification with the message data
        send_firebase_notification(
            token=device_token,
            type=obj.type.type
        )
        

if not admin.site.is_registered(UserDevice):
    admin.site.register(UserDevice)

if not admin.site.is_registered(UserNotification):
    admin.site.register(UserNotification, UserNotificationAdmin)
    
if not admin.site.is_registered(UserNotificationType):
    admin.site.register(UserNotificationType)

if not admin.site.is_registered(UserData):
    admin.site.register(UserData)
