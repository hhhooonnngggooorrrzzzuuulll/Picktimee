from rest_framework import serializers
from .models import CalendarEvent

class CalendarEventSerializer(serializers.ModelSerializer):
    service_name = serializers.CharField(source='service.sname', read_only=True)
    worker_name = serializers.CharField(source='worker.wname', read_only=True)
    branch_name = serializers.CharField(source='branch.bname', read_only=True)
    date = serializers.SerializerMethodField()
    time = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()  # You can define your own logic for "Completed" or not

    class Meta:
        model = CalendarEvent
        fields = [
            'event_id',
            'description',
            'start_time',
            'end_time',
            'customer',
            'worker',
            'branch',
            'service',
            'service_name',
            'worker_name',
            'branch_name',
            'date',
            'time',
            'status',
        ]

    def get_date(self, obj):
        return obj.start_time.strftime('%Y-%m-%d')

    def get_time(self, obj):
        return obj.start_time.strftime('%H:%M')

    def get_status(self, obj):
        from django.utils import timezone
        return "Completed" if obj.end_time < timezone.now() else "Upcoming"


