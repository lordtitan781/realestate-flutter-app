import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/land.dart';
import '../models/eoi.dart';
import '../models/destination.dart';
import '../models/project_milestone.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    return 'http://localhost:8080/api';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Auth Endpoints
  static Future<Map<String, dynamic>> login(String email, String password, {String? role}) async {
    final payload = {"email": email, "password": password};
    if (role != null) payload['role'] = role;
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password, "role": role}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }

  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(email),
    );
    if (response.statusCode != 200) throw Exception('Failed to request reset');
  }

  static Future<void> verifyOtp(String email, String otp) async {
    final payload = {"email": email, "otp": otp};
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );
    if (response.statusCode != 200) throw Exception('OTP verification failed');
  }

  static Future<void> resetPassword(String email, String otp, String newPassword) async {
    final payload = {"email": email, "otp": otp, "newPassword": newPassword};
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );
    if (response.statusCode != 200) throw Exception('Password reset failed');
  }

  // Project Endpoints
  static Future<List<Project>> getProjects({String? theme}) async {
    String url = '$baseUrl/projects';
    if (theme != null && theme != 'All') {
      url += '?theme=${Uri.encodeComponent(theme)}';
    }
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Project.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  static Future<Project> createProject(Project project) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects/create'),
      headers: await _getHeaders(),
      body: json.encode(project.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create project');
    }
  }

  // Land Endpoints
  static Future<List<Land>> getLands() async {
    final response = await http.get(Uri.parse('$baseUrl/lands'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Land.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load lands');
    }
  }

  static Future<List<Land>> getAvailableLands() async {
    final response = await http.get(Uri.parse('$baseUrl/lands/available'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Land.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load available lands');
    }
  }

  static Future<Land> submitLand(Land land) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lands'),
      headers: await _getHeaders(),
      body: json.encode(land.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Land.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit land');
    }
  }

  static Future<Land> updateLandReview(int landId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/lands/$landId/review'),
      headers: await _getHeaders(),
      body: json.encode(status),
    );
    if (response.statusCode == 200) {
      return Land.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update land review');
    }
  }

  // Eoi Endpoints
  static Future<Eoi> submitEOI(Eoi eoi) async {
    final response = await http.post(
      Uri.parse('$baseUrl/eois'),
      headers: await _getHeaders(),
      body: json.encode(eoi.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Eoi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit EOI');
    }
  }

  static Future<List<Eoi>> getInvestorEOIs(int investorId) async {
    final response = await http.get(Uri.parse('$baseUrl/eois/investor/$investorId'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Eoi.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load investor EOIs');
    }
  }

  // Destinations
  static Future<List<dynamic>> _getRawDestinations() async {
    final response = await http.get(Uri.parse('$baseUrl/destinations/all'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load destinations');
    }
  }

  /// Returns raw JSON list of destinations. Useful for internal utilities.
  static Future<List<dynamic>> getRawDestinationsForInternalUse() async {
    return await _getRawDestinations();
  }

  /// Returns typed list of [Destination] objects fetched from the backend.
  static Future<List<Destination>> getDestinations() async {
    final raw = await _getRawDestinations();
    return raw.map((d) => Destination.fromJson(d as Map<String, dynamic>)).toList();
  }

  // Finance endpoints
  static Future<double> calculateROI(double investment, double finalValue) async {
    final url = Uri.parse('$baseUrl/finance/roi?investment=${investment.toString()}&finalValue=${finalValue.toString()}');
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return (json.decode(response.body) as num).toDouble();
    } else {
      throw Exception('Failed to calculate ROI');
    }
  }

  static Future<Map<String, double>> getScenarioROI(double investment) async {
    final url = Uri.parse('$baseUrl/finance/roi/scenarios?investment=${investment.toString()}');
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } else {
      throw Exception('Failed to fetch ROI scenarios');
    }
  }

  static Future<double> calculateIRR(List<double> cashFlows) async {
    final response = await http.post(
      Uri.parse('$baseUrl/finance/irr'),
      headers: await _getHeaders(),
      body: json.encode(cashFlows),
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as num).toDouble();
    } else {
      throw Exception('Failed to calculate IRR');
    }
  }

  // Admin endpoints
  static Future<List<Land>> getPendingLands() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/pending-lands'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Land.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load pending lands');
    }
  }

  static Future<Land> approveLand(int landId, {String? adminNotes}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/approve/$landId'),
      headers: await _getHeaders(),
      body: json.encode(adminNotes ?? ''),
    );
    if (response.statusCode == 200) {
      return Land.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to approve land');
    }
  }

  static Future<Land> rejectLand(int landId, {String? adminNotes}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/reject/$landId'),
      headers: await _getHeaders(),
      body: json.encode(adminNotes ?? ''),
    );
    if (response.statusCode == 200) {
      return Land.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to reject land');
    }
  }

  static Future<Project> convertLandToProject(int landId, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/convert/$landId'),
      headers: await _getHeaders(),
      body: json.encode(payload),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to convert land to project');
    }
  }

  // Project Milestones
  static Future<List<ProjectMilestone>> getProjectMilestones(int projectId) async {
    final response = await http.get(Uri.parse('$baseUrl/projects/$projectId/milestones'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((d) => ProjectMilestone.fromJson(d as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load project milestones');
    }
  }

  static Future<ProjectMilestone> addProjectMilestone(ProjectMilestone milestone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/milestones/add'),
      headers: await _getHeaders(),
      body: json.encode(milestone.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProjectMilestone.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add milestone');
    }
  }

  static Future<ProjectMilestone> updateMilestoneStatus(int milestoneId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/milestones/$milestoneId/status?status=${Uri.encodeComponent(status)}'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return ProjectMilestone.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update milestone status');
    }
  }
}
