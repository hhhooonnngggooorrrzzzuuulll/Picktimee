"""
Django settings for Backend project.

Generated by 'django-admin startproject' using Django 4.1.5.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/4.1/ref/settings/
"""

from pathlib import Path
import psycopg2


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent



# def connectDB():
#     try:
#         con = psycopg2.connect(
#             host='192.168.0.15',
#             dbname='time_roder',  # Corrected to dbname
#             user='PostgreSQL',
#             password='123',
#             port='5432',
#         )
#         return con
#     except psycopg2.Error as e:
#         print("Unable to connect to the database.")
#         print(e)
#         return None

# def disconnectDB(con):
#     if con:
#         con.close()

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/4.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-x1m9qh9tf-8^=f5hl)7n7bbq6do6)zm4ucj&@f4*^5zsf8z%f#'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'App', 
    'rest_framework',
    'rest_framework_simplejwt.token_blacklist', 
    'corsheaders',
]


REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}


MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',

]
# settings.py



ROOT_URLCONF = 'Backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'Backend.wsgi.application'


# Database
# https://docs.djangoproject.com/en/4.1/ref/settings/#databases

# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',  # Or your preferred backend
        'NAME': 'time_order',
        'USER': 'postgres',
        'PASSWORD': '1004',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
APPEND_SLASH=False

# Password validation
# https://docs.djangoproject.com/en/4.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


CORS_ALLOW_ALL_ORIGINS = True  # Allow all (for development)
# OR specify allowed origins
CORS_ALLOWED_ORIGINS = [
    "http://localhost:64529",
    "http://127.0.0.1:8000",  # Django API
]



# Internationalization
# https://docs.djangoproject.com/en/4.1/topics/i18n/

LANGUAGE_CODE = 'en-us'
USE_I18N = True


TIME_ZONE = 'Asia/Ulaanbaatar'  # Set to your desired timezone
USE_TZ = True



# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.1/howto/static-files/

STATIC_URL = 'static/'
import os

# The base directory of your project
# Configure where uploaded media files should be stored
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')


# Default primary key field type
# https://docs.djangoproject.com/en/4.1/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
