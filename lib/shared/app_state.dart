import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land.dart';
import '../models/project.dart';
import '../models/eoi.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  List<Land> _lands = [];
  List<Project> _projects = [];
  List<Eoi> _userEOIs = [];

  List<Land> get pendingLands => _lands.where((l) => l.reviewStatus == 'PENDING').toList();
  List<Land> get approvedLands => _lands.where((l) => l.reviewStatus == 'APPROVED').toList();
  List<Project> get projects => _projects;
  
  List<Project> get investorPortfolio {
    final eoiProjectIds = _userEOIs.map((e) => e.projectId).toSet();
    return _projects.where((p) => eoiProjectIds.contains(p.id)).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _currentUserId;
  String? _currentUserRole;
  String? _currentUserEmail;

  double? _minBudget;
  double? _maxBudget;
  String? _riskProfile;

  int? get currentUserId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  String? get currentUserEmail => _currentUserEmail;
  double? get minBudget => _minBudget;
  double? get maxBudget => _maxBudget;
  String? get riskProfile => _riskProfile;

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Fetch projects - Everyone can see these
      _projects = await ApiService.getProjects();
      
      // 2. Fetch lands - Only Admin and Landowner should see these
      if (_currentUserRole == 'ADMIN' || _currentUserRole == 'LANDOWNER') {
        _lands = await ApiService.getLands();
      }

      // 3. Fetch EOIs - Only Investor should see these
      if (_currentUserRole == 'INVESTOR' && _currentUserId != null) {
        _userEOIs = await ApiService.getInvestorEOIs(_currentUserId!);
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      // Don't rethrow here if we want the login to succeed even if initial fetch fails
      // but typically we want the data.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch projects filtered by theme from backend
  Future<void> fetchProjectsByTheme(String theme) async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await ApiService.getProjects(theme: theme);
    } catch (e) {
      debugPrint("Error fetching themed projects: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, {String? role}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.login(email, password, role: role);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', response['token']);
      await prefs.setString('user_role', response['role']);
      _currentUserId = response['userId'];
      _currentUserRole = response['role'];
      _currentUserEmail = response['email'];
      _minBudget = (response['minBudget'] as num?)?.toDouble();
      _maxBudget = (response['maxBudget'] as num?)?.toDouble();
      _riskProfile = response['riskProfile'] as String?;
      
      // Fetch data based on the newly acquired role
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email,
    String password,
    String role, {
    double? minBudget,
    double? maxBudget,
    String? riskProfile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.register(
        email,
        password,
        role,
        minBudget: minBudget,
        maxBudget: maxBudget,
        riskProfile: riskProfile,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', response['token']);
      await prefs.setString('user_role', response['role']);
      _currentUserId = response['userId'];
      _currentUserRole = response['role'];
      _currentUserEmail = response['email'];
      _minBudget = (response['minBudget'] as num?)?.toDouble();
      _maxBudget = (response['maxBudget'] as num?)?.toDouble();
      _riskProfile = response['riskProfile'] as String?;
      
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint("Registration error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    _currentUserId = null;
    _currentUserRole = null;
    _currentUserEmail = null;
    _minBudget = null;
    _maxBudget = null;
    _riskProfile = null;
    _lands = [];
    _projects = [];
    _userEOIs = [];
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    try {
      final newProj = await ApiService.createProject(project);
      _projects.add(newProj);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding project: $e");
    }
  }

  Future<void> updateProjectStage(int projectId, String stage) async {
    try {
      final updated = await ApiService.updateProjectStage(projectId, stage);
      final index = _projects.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        _projects[index] = updated;
      } else {
        _projects.add(updated);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating project stage: $e");
      rethrow;
    }
  }

  Future<void> addLand(Land land) async {
    try {
      final newLand = await ApiService.submitLand(land);
      _lands.add(newLand);
      notifyListeners();
    } catch (e) {
      debugPrint("Error submitting land: $e");
    }
  }

  // Admin actions using the new admin endpoints
  Future<void> fetchPendingFromServer() async {
    try {
      _isLoading = true;
      notifyListeners();
      _lands = await ApiService.getPendingLands();
    } catch (e) {
      debugPrint('Error fetching pending lands: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adminApproveLand(int landId) async {
    try {
      final updated = await ApiService.approveLand(landId, adminNotes: 'Approved via admin UI');
      // refresh list
      await fetchPendingFromServer();
      notifyListeners();
    } catch (e) {
      debugPrint('Error approving land via admin API: $e');
    }
  }

  Future<void> adminRejectLand(int landId, {String? adminNotes}) async {
    try {
      final updated = await ApiService.rejectLand(
        landId,
        adminNotes: adminNotes ?? 'Rejected via admin UI',
      );
      await fetchPendingFromServer();
      notifyListeners();
    } catch (e) {
      debugPrint('Error rejecting land via admin API: $e');
    }
  }

  Future<Project?> adminConvertLand(int landId, Map<String, dynamic> payload) async {
    try {
      final project = await ApiService.convertLandToProject(landId, payload);
      _projects.add(project);
      await fetchPendingFromServer();
      notifyListeners();
      return project;
    } catch (e) {
      debugPrint('Error converting land: $e');
      return null;
    }
  }

  Future<void> approveLand(int landId, String landName, String location) async {
    try {
      // First approve the land in the backend
      await ApiService.updateLandReview(landId, 'APPROVED');
      
      // Refresh lands to get updated status
      _lands = await ApiService.getLands();

      // Create a new project linked to this approved land
      final newProject = Project(
        landId: landId,
        projectName: '$landName Project',
        location: location,
        landSize: 0.0,
        investmentRequired: 0.0,
        expectedROI: 0.0,
        expectedIRR: 0.0,
        stage: 'LAND_APPROVED',
      );
      
      // Add project to backend and state
      await addProject(newProject);
      
      // Fetch all projects again to ensure investors can see the new project
      _projects = await ApiService.getProjects();
      notifyListeners();
    } catch (e) {
      debugPrint("Error approving land: $e");
    }
  }

  Future<Project?> convertLandToProject(int landId, Map<String, dynamic> payload) async {
    try {
      final project = await ApiService.convertLandToProject(landId, payload);
      _projects.add(project);
      
      // Refresh lands to remove from pending list
      _lands = await ApiService.getLands();
      
      // Fetch all projects to ensure everyone can see it
      _projects = await ApiService.getProjects();
      
      notifyListeners();
      return project;
    } catch (e) {
      debugPrint('Error converting land: $e');
      return null;
    }
  }

  Future<bool> addToPortfolio(Project project) async {
    if (project.id == null || _currentUserId == null) return false;
    try {
      final eoi = Eoi(investorId: _currentUserId!, projectId: project.id!);
      await ApiService.submitEOI(eoi);
      
      // Always fetch the latest EOIs to ensure portfolio is up-to-date
      _userEOIs = await ApiService.getInvestorEOIs(_currentUserId!);
      
      // Also refresh projects to ensure we have the latest data
      _projects = await ApiService.getProjects();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error submitting EOI: $e");
      rethrow; // Let caller handle the error
    }
  }

  Future<bool> checkEOIExists(int projectId) async {
    if (_currentUserId == null) return false;
    try {
      return await ApiService.checkEOIExists(_currentUserId!, projectId);
    } catch (e) {
      debugPrint("Error checking EOI: $e");
      return false;
    }
  }

  bool hasEOIForProject(int projectId) {
    return _userEOIs.any((eoi) => eoi.projectId == projectId);
  }
}
