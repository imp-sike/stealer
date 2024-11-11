from django.db import models

class UserDevice(models.Model):
    device_name = models.CharField(max_length=200)
    device_token = models.TextField()
    published_date = models.DateTimeField(auto_now_add=True)
    
    
    def __str__(self):
        return self.device_name

class UserNotificationType(models.Model):
    type = models.CharField(max_length=200)
    description = models.TextField()    
    
    def __str__(self):
        return f"{self.type}"

class UserNotification(models.Model):
    message = models.TextField()
    device = models.ForeignKey(UserDevice, on_delete=models.CASCADE)
    type = models.ForeignKey(UserNotificationType, on_delete=models.CASCADE)
    
    def __str__(self):
        return f"Notification for {self.device.device_name}"
    
class UserData(models.Model):
    data = models.TextField()
    device = models.TextField()
    
    def __str__(self):
        return f"{self.device}"
    
class UploadedFile(models.Model):
    file = models.FileField(upload_to='uploads/')
    uploaded_at = models.DateTimeField(auto_now_add=True)