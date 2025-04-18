from rest_framework_simplejwt.exceptions import TokenError, InvalidToken
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection
from .serializers import CalendarEventSerializer
from .models import CalendarEvent
import json
from django.conf import settings 
from django.utils import timezone
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import get_user_model


Customer = get_user_model()

@csrf_exempt
def register_customer(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        cname = data.get('cname')
        cemail = data.get('cemail')
        cphone = data.get('cphone')
        password = data.get('password')

        if Customer.objects.filter(cemail=cemail).exists():
            return JsonResponse({'error': 'Email already exists'}, status=400)

        customer = Customer.objects.create_user(
            cname=cname,
            cemail=cemail,
            cphone=cphone,
            password=password
        )

        return JsonResponse({'message': 'Customer registered successfully'}, status=201)





@csrf_exempt
@api_view(['POST'])
def login_customer(request):
    cemail = request.data.get('cemail')
    password = request.data.get('password')

    try:
        customer = Customer.objects.get(cemail=cemail)
    except Customer.DoesNotExist:
        return Response({'error': 'Invalid email or password'}, status=status.HTTP_400_BAD_REQUEST)

    if customer.check_password(password):
        refresh = RefreshToken.for_user(customer)

        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'id': customer.customer_id,
                'email': customer.cemail,
                'name': customer.cname,
            }
        })
    else:
        return Response({'error': 'Invalid email or password'}, status=status.HTTP_400_BAD_REQUEST)



@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def logout_customer(request):
    try:
        data = json.loads(request.body)
        refresh_token = data.get('refresh')

        if not refresh_token:
            return JsonResponse({'error': 'Refresh token required'}, status=400)

        token = RefreshToken(refresh_token)
        token.blacklist()

        return JsonResponse({'message': 'Logout successful'}, status=200)

    except TokenError as e:
        return JsonResponse({'error': 'Invalid token'}, status=400)

###########################################################################################################################################




def customer_list(request):
    if request.method == 'GET':
        try:
            page = int(request.GET.get('page', 1))
            limit = 10  # Number of customers per page
            offset = (page - 1) * limit

            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT *
                    FROM t_customer
                    LIMIT %s OFFSET %s;
                """, [limit, offset])
                rows = cursor.fetchall()

            # Map the rows to a dictionary structure matching the React table's requirements
            customers = [
                {
                    "customer_id": row[0],
                    "cname": row[1],
                    "cemail": row[2],
                    "cphone": row[3],
                }
                for row in rows
            ]

            return JsonResponse(customers, safe=False, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Invalid request method'}, status=400)

@csrf_exempt
def add_customer(request):
    if request.method == "POST":
        try:
            # Parse the request body
            data = json.loads(request.body)
            cname = data.get("cname")
            cemail = data.get("cemail")
            cphone = data.get("cphone")

            # Generate a new customer_id (assuming auto-increment is not used)
            with connection.cursor() as cursor:
                cursor.execute("SELECT COALESCE(MAX(customer_id), 0) + 1 FROM t_customer")
                customer_id = cursor.fetchone()[0]

            # Insert the new customer record
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO t_customer (customer_id, cname, cemail, cphone)
                    VALUES (%s, %s, %s, %s)
                    """,
                    [customer_id, cname, cemail, cphone]
                )

            return JsonResponse({"message": "Customer added successfully", "customer_id": customer_id}, status=201)
        
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    return JsonResponse({"error": "Invalid request method"}, status=405)


###########################################################################################################################################


def branch_list(request):
    if request.method == 'GET':
        try:
            page = int(request.GET.get('page', 1))
            limit = 10  # Number of branches per page
            offset = (page - 1) * limit

            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT branch_id, bname, blocation, bimage
                    FROM t_branch
                    LIMIT %s OFFSET %s;
                """, [limit, offset])
                rows = cursor.fetchall()

            branches = [
                {
                    "branch_id": row[0],
                    "bname": row[1],
                    "blocation": row[2],
                    # Generate full image URL
                    "bimage": request.build_absolute_uri(settings.MEDIA_URL + row[3]) if row[3] else None,
                }
                for row in rows
            ]

            return JsonResponse(branches, safe=False, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=400)


@csrf_exempt
def add_branch(request):
    if request.method == "POST":
        try:
            # Parse the request body
            data = json.loads(request.body)
            bname = data.get("bname")
            blocation = data.get("blocation")

            # Generate a new branch_id (handling case when no rows exist)
            with connection.cursor() as cursor:
                cursor.execute('SELECT MAX(branch_id) FROM t_branch')  # Use the correct column name
                result = cursor.fetchone()
                
                # If no rows exist, start with 1; otherwise, increment the max branch_id
                branch_id = result[0] + 1 if result[0] is not None else 1

            # Insert the new branch record
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO t_branch (branch_id, bname, blocation)
                    VALUES (%s, %s, %s)
                    """,
                    [branch_id, bname, blocation]
                )

            return JsonResponse({"message": "Branch added successfully", "branch_id": branch_id}, status=201)
        
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    return JsonResponse({"error": "Invalid request method"}, status=405)



###########################################################################################################################################



def role_list(request):
    if request.method == 'GET':
        try:
            page = int(request.GET.get('page', 1))
            limit = 10  # Number of roles per page
            offset = (page - 1) * limit

            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT role_id, role_name
                    FROM t_role
                    LIMIT %s OFFSET %s;
                """, [limit, offset])
                rows = cursor.fetchall()

            # Map the rows to a dictionary structure matching the React table's requirements
            roles = [
                {
                    "role_id": row[0],
                    "role_name": row[1],
                }
                for row in rows
            ]

            return JsonResponse(roles, safe=False, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Invalid request method'}, status=400)



@csrf_exempt
def add_role(request):
    if request.method == "POST":
        try:
            # Parse the request body
            data = json.loads(request.body)
            role_name = data.get("role_name")

            # Generate a new role_id (handling case when no rows exist)
            with connection.cursor() as cursor:
                cursor.execute('SELECT MAX(role_id) FROM t_role')  # Use the correct column name
                result = cursor.fetchone()
                
                # If no rows exist, start with 1; otherwise, increment the max role_id
                role_id = result[0] + 1 if result[0] is not None else 1

            # Insert the new role record
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO t_role (role_id, role_name)
                    VALUES (%s, %s)
                    """,
                    [role_id, role_name]
                )

            return JsonResponse({"message": "Role added successfully", "role_id": role_id}, status=201)
        
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    return JsonResponse({"error": "Invalid request method"}, status=405)



###########################################################################################################################################

from django.core.paginator import Paginator

def worker_list(request):
    if request.method == 'GET':
        try:
            page = int(request.GET.get('page', 1))
            limit = 10  # Number of workers per page

            workers_qs = Worker.objects.select_related('role', 'branch').all()
            paginator = Paginator(workers_qs, limit)
            current_page = paginator.get_page(page)

            workers = [
                {
                    "worker_id": worker.worker_id,
                    "wfirst": worker.wfirst,
                    "wname": worker.wname,
                    "wphone": worker.wphone,
                    "role_name": worker.role.role_name if worker.role else None,
                    "bname": worker.branch.bname if worker.branch else None,
                    "worker_image": worker.worker_image.url if worker.worker_image else None,
                }
                for worker in current_page
            ]

            return JsonResponse(workers, safe=False, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Invalid request method'}, status=400)


@csrf_exempt
def add_worker(request):
    if request.method == "POST":
        try:
            # Parse the request body
            data = json.loads(request.body)
            wfirst = data.get("wfirst")
            wname = data.get("wname")
            wphone = data.get("wphone")
            role_id = data.get("role_id")
            branch_id = data.get("branch_id")

            # Validate inputs
            if not all([wfirst, wname, wphone, role_id]):
                return JsonResponse({"error": "Missing required fields"}, status=400)

            # Convert branch_id to an integer or handle missing/empty branch_id
            branch_id = int(branch_id) if branch_id else None

            # Insert the new worker record
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO t_worker (wfirst, wname, wphone, role_id, branch_id)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING worker_id
                    """,
                    [wfirst, wname, wphone, role_id, branch_id]
                )
                worker_id = cursor.fetchone()[0]

            return JsonResponse({"message": "Worker added successfully", "worker_id": worker_id}, status=201)
        
        except ValueError as e:
            return JsonResponse({"error": "Invalid input: branch_id must be an integer"}, status=400)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    return JsonResponse({"error": "Invalid request method"}, status=405)




def get_made_by_worker(request, worker_id):
    made_items = Made.objects.filter(made_worker_id=worker_id)

    made_data = [{
        "made_id": made.made_id,
        "made_image": request.build_absolute_uri(made.made_image.url) if made.made_image else None,
        "worker_name": str(made.made_worker),
        "service_category": str(made.made_service_category),
        "comment": made.comment
    } for made in made_items]

    return JsonResponse({"made_works": made_data})



###########################################################################################################################################


def category_list(request):
    if request.method == 'GET':
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT category_id, cname, cdescription FROM t_service_category;")
                category_rows = cursor.fetchall()

            categories = [
                {
                    "category_id": row[0],
                    "cname": row[1],
                    "cdescription": row[2]
                }
                for row in category_rows
            ]

            return JsonResponse(categories, safe=False, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=400)




def add_category(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            cname = data.get("cname")
            cdescription = data.get("cdescription", "")

            if not cname:
                return JsonResponse({'error': 'Category name is required'}, status=400)

            with connection.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO t_service_category (cname, cdescription) VALUES (%s, %s) RETURNING category_id;",
                    [cname, cdescription]
                )
                new_category_id = cursor.fetchone()[0]

            return JsonResponse({
                "message": "Category added successfully",
                "category": {
                    "category_id": new_category_id,
                    "cname": cname,
                    "cdescription": cdescription
                }
            }, status=201)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=400)

#################################################################################################################################################

from django.http import JsonResponse
from .models import ServiceCategory, Service

def get_lash_services(request):
    # Corrected to filter by 'cname' instead of 'name'
    lash_category = ServiceCategory.objects.filter(cname='Сормуус').first()
    if lash_category:
        services = Service.objects.filter(category=lash_category)
        # Prepare the service data
        service_data = [{"service_id": service.service_id, 
                         "sname": service.sname, 
                         "sprice": str(service.sprice), 
                         "simage": service.simage.url if service.simage else None, 
                         "sduration": service.sduration} for service in services]
        
        # Prepare category data
        category_data = [{"cname": lash_category.cname}]
        
        return JsonResponse({"categories": category_data, "services": service_data})
    
    return JsonResponse({"categories": [], "services": []})




def get_brow_services(request):
    # Corrected to filter by 'cname' for 'brow' instead of 'lash'
    brow_category = ServiceCategory.objects.filter(cname='Шивээс').first()
    if brow_category:
        services = Service.objects.filter(category=brow_category)
        # Prepare the service data
        service_data = [{"service_id": service.service_id, 
                         "sname": service.sname, 
                         "sprice": str(service.sprice), 
                         "simage": service.simage.url if service.simage else None, 
                         "sduration": service.sduration} for service in services]
        
        # Prepare category data
        category_data = [{"cname": brow_category.cname}]
        
        return JsonResponse({"categories": category_data, "services": service_data})
    
    return JsonResponse({"categories": [], "services": []})


def get_manicure_services(request):
    # Filter by 'cname' for 'manicure'
    manicure_category = ServiceCategory.objects.filter(cname='Маникюр').first()
    if manicure_category:
        services = Service.objects.filter(category=manicure_category)
        # Prepare the service data
        service_data = [{"service_id": service.service_id, 
                         "sname": service.sname, 
                         "sprice": str(service.sprice), 
                         "simage": service.simage.url if service.simage else None, 
                         "sduration": service.sduration} for service in services]
        
        # Prepare category data
        category_data = [{"cname": manicure_category.cname}]
        
        return JsonResponse({"categories": category_data, "services": service_data})
    
    return JsonResponse({"categories": [], "services": []})

def get_pedicure_services(request):
    # Filter by 'cname' for 'pedicure'
    pedicure_category = ServiceCategory.objects.filter(cname='Педикюр').first()
    if pedicure_category:
        services = Service.objects.filter(category=pedicure_category)
        # Prepare the service data
        service_data = [{"service_id": service.service_id, 
                         "sname": service.sname, 
                         "sprice": str(service.sprice), 
                         "simage": service.simage.url if service.simage else None, 
                         "sduration": service.sduration} for service in services]
        
        # Prepare category data
        category_data = [{"cname": pedicure_category.cname}]
        
        return JsonResponse({"categories": category_data, "services": service_data})
    
    return JsonResponse({"categories": [], "services": []})


def get_skin_services(request):
    # Filter by 'cname' for 'skin'
    skin_category = ServiceCategory.objects.filter(cname='Гоо сайхан').first()
    if skin_category:
        services = Service.objects.filter(category=skin_category)
        # Prepare the service data
        service_data = [{"service_id": service.service_id, 
                         "sname": service.sname, 
                         "sprice": str(service.sprice), 
                         "simage": service.simage.url if service.simage else None, 
                         "sduration": service.sduration} for service in services]
        
        # Prepare category data
        category_data = [{"cname": skin_category.cname}]
        
        return JsonResponse({"categories": category_data, "services": service_data})
    
    return JsonResponse({"categories": [], "services": []})


def get_piercing_services(request):
    # Filter by 'cname' for 'piercing'
    piercing_category = ServiceCategory.objects.filter(cname='Цоолох').first()
    if piercing_category:
        services = Service.objects.filter(category=piercing_category)
        # Prepare the service data
        service_data = [{"service_id": service.service_id, 
                         "sname": service.sname, 
                         "sprice": str(service.sprice), 
                         "simage": service.simage.url if service.simage else None, 
                         "sduration": service.sduration} for service in services]
        
        # Prepare category data
        category_data = [{"cname": piercing_category.cname}]
        
        return JsonResponse({"categories": category_data, "services": service_data})
    
    return JsonResponse({"categories": [], "services": []})



############################################################################################################################################3


def service_list(request):
    if request.method == 'GET':
        try:
            page = int(request.GET.get('page', 1))
            limit = 10  # Number of services per page
            offset = (page - 1) * limit

            with connection.cursor() as cursor:
                # Fetch service categories
                cursor.execute("SELECT category_id, cname, cdescription FROM t_service_category;")
                category_rows = cursor.fetchall()
                categories = [
                    {
                        "category_id": row[0],
                        "cname": row[1],
                        "cdescription": row[2]
                    }
                    for row in category_rows
                ]

                # Fetch services with category info
                cursor.execute("""
                    SELECT s.service_id, s.sname, s.sprice, s.sduration, s.simage, s.scomment, c.category_id, c.cname
                    FROM t_service s
                    LEFT JOIN t_service_category c ON s.category_id = c.category_id
                    LIMIT %s OFFSET %s;
                """, [limit, offset])
                service_rows = cursor.fetchall()

                services = [
                    {
                        "service_id": row[0],
                        "sname": row[1],
                        "sprice": row[2],
                        "sduration": row[3],
                        "simage": row[4] and f"{settings.MEDIA_URL}{row[4]}",
                        "scomment": row[5],
                        "category": {
                            "category_id": row[6],
                            "cname": row[7]
                        } if row[6] else None
                    }
                    for row in service_rows
                ]

            return JsonResponse({"categories": categories, "services": services}, safe=False, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=400)



from .models import ServiceCategory

@csrf_exempt
def add_service(request):
    if request.method == 'POST':
        try:
            # Parse the request body
            data = json.loads(request.body)
            sname = data.get('sname')
            sprice = data.get('sprice')
            sduration = data.get('sduration')
            simage = data.get('simage')  # assuming image URL or base64 string
            scomment = data.get('scomment', "")
            category_id = data.get('category_id')

            # Debugging print (optional: log these values for debugging in production)
            print("Received data:", data)

            # Validate input
            if not sname or sprice is None or sduration is None:
                return JsonResponse({'error': 'Missing required fields'}, status=400)

            # Try to cast sprice to a decimal
            try:
                sprice = float(sprice)  # Cast to float for the DecimalField
            except ValueError:
                return JsonResponse({'error': 'Invalid value for sprice. It should be a decimal number.'}, status=400)

            # Validate the types
            if not isinstance(sduration, str):
                return JsonResponse({'error': f"Invalid type for 'sduration'. Expected str, got {type(sduration).__name__}"}, status=400)

            if sprice < 0:
                return JsonResponse({'error': 'Price must be a positive value'}, status=400)

            if len(sduration.strip()) == 0:
                return JsonResponse({'error': 'Duration cannot be empty'}, status=400)

            # Validate category ID
            if category_id:
                try:
                    category = ServiceCategory.objects.get(category_id=category_id)
                except ServiceCategory.DoesNotExist:
                    return JsonResponse({'error': 'Category not found'}, status=400)
            else:
                category = None

            # Insert into the database
            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO t_service (sname, sprice, sduration, simage, scomment, category_id)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING service_id;
                """, [sname, sprice, sduration, simage, scomment, category_id])
                service_id = cursor.fetchone()

            if service_id:
                return JsonResponse({'message': 'Service added successfully', 'service_id': service_id[0]}, status=201)
            else:
                return JsonResponse({'error': 'Service insertion failed'}, status=500)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON format'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=405)


################################################################################################################################################


@csrf_exempt
def edit_service(request, service_id):
    if request.method == 'PUT':  # Use PUT method for updating
        try:
            data = json.loads(request.body)
            sname = data.get('sname')
            sprice = data.get('sprice')
            sduration = data.get('sduration')

            if not sname or sprice is None or sduration is None:
                return JsonResponse({'error': 'Missing required fields'}, status=400)

            try:
                sprice = int(sprice)
            except ValueError:
                return JsonResponse({'error': 'Invalid value for sprice. It should be an integer.'}, status=400)

            if not isinstance(sduration, str):
                return JsonResponse({'error': f"Invalid type for 'sduration'. Expected str, got {type(sduration).__name__}"}, status=400)

            if sprice < 0:
                return JsonResponse({'error': 'Price must be a positive value'}, status=400)

            if len(sduration.strip()) == 0:
                return JsonResponse({'error': 'Duration cannot be empty'}, status=400)

            with connection.cursor() as cursor:
                cursor.execute("""
                    UPDATE t_service
                    SET sname = %s, sprice = %s, sduration = %s
                    WHERE service_id = %s;
                """, [sname, sprice, sduration, service_id])

                if cursor.rowcount > 0:
                    return JsonResponse({'message': 'Service updated successfully'}, status=200)
                else:
                    return JsonResponse({'error': 'Service not found or no changes made'}, status=404)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON format'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=405)



@csrf_exempt
def delete_service(request, service_id):
    if request.method == 'DELETE':
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    DELETE FROM t_service
                    WHERE service_id = %s;
                """, [service_id])

                if cursor.rowcount > 0:
                    return JsonResponse({'message': 'Service deleted successfully'}, status=200)
                else:
                    return JsonResponse({'error': 'Service not found'}, status=404)

        except Exception as e:
            # Log the error (optional: configure logging in settings.py)
            return JsonResponse({'error': 'An error occurred: {}'.format(str(e))}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=405)  # 405 for invalid method


##############################################################################################################################################


# Create Event
@api_view(['POST'])
def create_event(request):
    if request.method == 'POST':
        serializer = CalendarEventSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()  
            return Response(serializer.data, status=status.HTTP_201_CREATED)  
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)  

# List Events
@api_view(['GET'])
def list_events(request):
    # Retrieve query parameters
    worker_id = request.query_params.get('worker') 
    branch = request.query_params.get('branch')  

    # Filter events
    events = CalendarEvent.objects.all()
    if worker_id:
        events = events.filter(worker_id=worker_id)
    if branch:
        events = events.filter(branch=branch)

    # Serialize and return response
    serializer = CalendarEventSerializer(events, many=True)
    return Response(serializer.data)


# Get Event by ID
@api_view(['GET'])
def get_event(request, event_id):
    try:
        event = CalendarEvent.objects.get(event_id=event_id)  
    except CalendarEvent.DoesNotExist:
        return Response({"detail": "Event not found."}, status=status.HTTP_404_NOT_FOUND)  

    serializer = CalendarEventSerializer(event)  
    return Response(serializer.data)  

# Update Event
@api_view(['PUT'])
def update_event(request, event_id):
    try:
        event = CalendarEvent.objects.get(event_id=event_id)  
    except CalendarEvent.DoesNotExist:
        return Response({"detail": "Event not found."}, status=status.HTTP_404_NOT_FOUND)  

    serializer = CalendarEventSerializer(event, data=request.data) 
    if serializer.is_valid():
        serializer.save() 
        return Response({"status": "success", "data": serializer.data}) 
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
def delete_event(request, event_id):
    try:
        event = CalendarEvent.objects.get(event_id=event_id) 
    except CalendarEvent.DoesNotExist:
        return Response({"detail": "Event not found."}, status=status.HTTP_404_NOT_FOUND) 

    event.delete() 
    return Response({"detail": "Event deleted successfully."}, status=status.HTTP_204_NO_CONTENT) 


###########################################################################################################################################

from datetime import datetime, timedelta
from .models import CalendarEvent, Service, Customer, Worker, Branch
from django.utils import timezone
from .models import *

@csrf_exempt
@api_view(["GET", "POST"])
def book_service(request):
    if request.method == "GET":
        branches = list(Branch.objects.values("branch_id", "bname"))
        workers = list(Worker.objects.values("worker_id", "wfirst"))
        services = list(Service.objects.values("service_id", "sname"))

        return JsonResponse({
            "branches": [{"id": b["branch_id"], "name": b["bname"]} for b in branches],
            "workers": [{"id": w["worker_id"], "name": w["wfirst"]} for w in workers],
            "services": [{"id": s["service_id"], "name": s["sname"]} for s in services],
        })

    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            service_id = data.get("service_id")
            customer_id = data.get("customer_id")
            worker_id = data.get("worker_id")
            branch_id = data.get("branch_id")
            date_str = data.get("date")
            time_str = data.get("time")

            if not (service_id and customer_id and branch_id and date_str and time_str):
                return JsonResponse({"error": "Missing required fields"}, status=400)

            start_time = datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %I:%M %p")
            end_time = start_time + timedelta(hours=1)

            # Check if worker is booked
            if worker_id:
                worker_booked = CalendarEvent.objects.filter(
                    worker_id=worker_id,
                    start_time__lt=end_time,
                    end_time__gt=start_time,
                ).exists()
                if worker_booked:
                    return JsonResponse({"error": "Worker is already booked"}, status=400)

            event = CalendarEvent.objects.create(
                service_id=service_id,
                customer_id=customer_id,
                worker_id=worker_id,
                branch_id=branch_id,
                start_time=start_time,
                end_time=end_time,
                description=f"Booking for service {service_id} at branch {branch_id}",
            )

            return JsonResponse({"message": "Booking successful", "event_id": event.event_id}, status=201)

        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)

    return JsonResponse({"error": "Invalid request method"}, status=405)


@csrf_exempt
def get_weekly_bookings(request, worker_id):
    start_of_week = timezone.now().date() - timedelta(days=timezone.now().weekday())
    end_of_week = start_of_week + timedelta(days=6)

    bookings = CalendarEvent.objects.filter(
        worker_id=worker_id,
        start_time__date__gte=start_of_week,
        start_time__date__lte=end_of_week
    ).order_by("start_time")

    return JsonResponse({"weekly_bookings": list(bookings.values())}, safe=False)

@csrf_exempt
def get_monthly_bookings(request, worker_id):
    start_of_month = timezone.now().replace(day=1)
    end_of_month = start_of_month + timedelta(days=30)

    bookings = CalendarEvent.objects.filter(
        worker_id=worker_id,
        start_time__date__gte=start_of_month,
        start_time__date__lte=end_of_month
    ).order_by("start_time")

    return JsonResponse({"monthly_bookings": list(bookings.values())}, safe=False)

####################################################################################################################################################






########################################################################################################################################################