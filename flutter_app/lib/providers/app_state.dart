import 'package:flutter/material.dart';
import 'package:quickserve/models/service_item.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/models/user_profile.dart';
import 'package:quickserve/services/auth_service.dart';
import 'package:quickserve/services/request_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final RequestService _requestService = RequestService();

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceItem> _services = [];
  List<ServiceRequest> _requests = [];
  ServiceRequest? _selectedRequest;

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ServiceItem> get services => _services;
  List<ServiceRequest> get requests => _requests;
  ServiceRequest? get selectedRequest => _selectedRequest;

  bool get isAuthenticated => _currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.customer;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _services = await _requestService.getServices();
      _currentUser = await _authService.getCurrentProfile();
      if (_currentUser != null) {
        await refreshRequests();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.login(email: email, password: password);
      await refreshRequests();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      await refreshRequests();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _requests = [];
    _selectedRequest = null;
    notifyListeners();
  }

  Future<void> refreshRequests() async {
    if (_currentUser == null) return;
    if (_currentUser!.role == UserRole.agent) {
      _requests = await _requestService.getAgentAssignedRequests(_currentUser!.id);
    } else {
      _requests = await _requestService.getCustomerRequests(_currentUser!.id);
    }
    notifyListeners();
  }

  Future<ServiceRequest?> createRequest({
    required String serviceId,
    required String serviceName,
    required String title,
    required String description,
    required RequestPriority priority,
    required DateTime preferredDateTime,
    required String serviceAddress,
  }) async {
    if (_currentUser == null) return null;
    _isLoading = true;
    notifyListeners();
    try {
      final req = await _requestService.createRequest(
        customerId: _currentUser!.id,
        serviceId: serviceId,
        serviceName: serviceName,
        title: title,
        description: description,
        priority: priority,
        preferredDateTime: preferredDateTime,
        serviceAddress: serviceAddress,
      );
      await refreshRequests();
      _isLoading = false;
      notifyListeners();
      return req;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelRequest(String requestId, String reason) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _requestService.cancelRequest(requestId, reason);
      await refreshRequests();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAgentStatus({
    required String requestId,
    required RequestStatus newStatus,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _requestService.updateAgentStatus(
        requestId: requestId,
        newStatus: newStatus,
        notes: notes,
      );
      await refreshRequests();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectRequest(ServiceRequest req) {
    _selectedRequest = req;
    notifyListeners();
  }
}
