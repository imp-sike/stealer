from django.apps import AppConfig
import firebase_admin
from firebase_admin import credentials, messaging
import os


base_dir = os.path.dirname(os.path.abspath(__file__))
firebase_path = os.path.join(base_dir, 'firebase.json')

# Initialize Firebase Admin with the service account key
cred = credentials.Certificate(firebase_path)
firebase_admin.initialize_app(cred)

class AppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'app'
