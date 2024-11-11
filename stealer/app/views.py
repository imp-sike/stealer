from rest_framework import viewsets
from .models import UserDevice, UserData, UploadedFile
from .serializers import UserDeviceSerializer, UserDataSerializer, UploadedFileSerializer
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.parsers import MultiPartParser, FormParser


class FileUploadViewSet(viewsets.ModelViewSet):
    queryset = UploadedFile.objects.all()
    serializer_class = UploadedFileSerializer
    parser_classes = (MultiPartParser, FormParser)

    def create(self, request, *args, **kwargs):
        files = request.FILES.getlist('files')  # Retrieve all files from 'files' key
        file_instances = []

        for file in files:
            file_instance = UploadedFile(file=file)
            file_instance.save()
            file_instances.append(file_instance)

        serializer = self.get_serializer(file_instances, many=True, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class UserDataViewSet(viewsets.ModelViewSet):
    queryset = UserData.objects.all()
    serializer_class = UserDataSerializer


class UserDeviceViewSet(viewsets.ModelViewSet):
    queryset = UserDevice.objects.all()
    serializer_class = UserDeviceSerializer
    
    @action(detail=False, methods=['post'], url_path='change')
    def add_or_update_device(self, request):
        device_name = request.data.get('device_name')
        device_token = request.data.get('device_token')

        if not device_name or not device_token:
            return Response(
                {"error": "Device name and token are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check if a device with the same name exists and update or create it
        device, created = UserDevice.objects.update_or_create(
            device_name=device_name,
            defaults={'device_token': device_token}
        )

        if created:
            return Response(
                {"message": "Device created successfully."},
                status=status.HTTP_201_CREATED
            )
        else:
            return Response(
                {"message": "Device updated successfully."},
                status=status.HTTP_200_OK
            )