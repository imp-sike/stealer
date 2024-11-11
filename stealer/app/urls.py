from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserDeviceViewSet, UserDataViewSet, FileUploadViewSet

router = DefaultRouter()
router.register(r'devices', UserDeviceViewSet)
router.register(r'data', UserDataViewSet)
router.register(r'upload', FileUploadViewSet, basename='file-upload')


urlpatterns = [
    path('', include(router.urls)),
]
