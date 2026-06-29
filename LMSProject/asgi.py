# LMSProject/asgi.py
import os

# Settings must be configured BEFORE importing anything that touches models.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "LMSProject.settings")

from django.core.asgi import get_asgi_application

# Initialise Django (populates the app registry) before importing routing,
# which pulls in consumers that import ORM models.
django_asgi_app = get_asgi_application()

from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
import chat.routing

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": AuthMiddlewareStack(
        URLRouter(chat.routing.websocket_urlpatterns)
    ),
})
