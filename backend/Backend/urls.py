from django.urls import path
from App.views import *
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path("customer/", customer_list, name='customer'),
    path("add_customer/", add_customer, name='add_customer'),
    path("branch/", branch_list, name='branch'),
    path("add_branch/", add_branch, name='add_branch'),
    path("role/", role_list, name='role'),
    path("add_role/", add_role, name='add_role'),
    path("worker/", worker_list, name='worker'),
    path("add_worker/", add_worker, name='add_worker'),
    path('made/worker/<int:worker_id>/', get_made_by_worker, name='get_made_by_worker'),
    path('categories/', category_list, name='category_list'),
    path('categories/add/', add_category, name='add_categories'),  
    path("service/", service_list, name='service'),
    path('service/add/', add_service, name='add_service'),
    path('edit_service/<int:service_id>/', edit_service, name='edit_service'),
    path('delete_service/<int:service_id>/', delete_service, name='delete_service'),
    path('calendar-events/', list_events, name='list-events'),  # Get all events
    path('calendar-events/<int:event_id>/', get_event, name='get-event'),  # Get a specific event by ID
    path('calendar-events/create/', create_event, name='create-event'),  # Create a new event
    path('calendar-events/update/<int:event_id>/', update_event, name='update-event'),  # Update an event
    path('calendar-events/delete/<int:event_id>/', delete_event, name='delete-event'),  # Delete an event
    path('get_lash_services/', get_lash_services, name='get_lash_services'),
    path('get_brow_services/', get_brow_services, name='get_brow_services'),
    path('get_manicure_services/', get_manicure_services, name='get_manicure_services'),
    path('get_pedicure_services/', get_pedicure_services, name='get_pedicure_services'),
    path('get_skin_services/', get_skin_services, name='get_skin_services'),
    path('get_piercing_services/', get_piercing_services, name='get_piercing_services'),
    path('book/', book_service, name="book_service"),
    path('register/', register_customer, name='register_customer'),
    path('login/', login_customer, name='login_customer'),
    path('logout/', logout_customer, name='logout_customer'),
    path('update/', update_customer, name='update_customer'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # path('service_search/', service_search, name='service_search'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)