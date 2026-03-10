import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/land.dart';
import '../models/eoi.dart';
import '../models/destination.dart';
import '../models/project_milestone.dart';
import 'package:flutter/foundation.dart';

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

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String role, {
    double? minBudget,
    double? maxBudget,
    String? riskProfile,
  }) async {
    final payload = <String, dynamic>{
      "email": email,
      "password": password,
      "role": role,
      if (minBudget != null) "minBudget": minBudget,
      if (maxBudget != null) "maxBudget": maxBudget,
      if (riskProfile != null) "riskProfile": riskProfile,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
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
    final headers = await _getHeaders();
    debugPrint('[API] GET $url with headers $headers');
    final response = await http.get(Uri.parse(url), headers: headers);
    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      debugPrint('[API] Parsed ${jsonResponse.length} projects');
      return jsonResponse.map((data) {
        debugPrint('[API] Project data: $data');
        return Project.fromJson(data);
      }).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  static Future<Project> createProject(Project project) async {
    final url = '$baseUrl/projects/create';
    final headers = await _getHeaders();
    final body = json.encode(project.toJson());
    debugPrint('[API] POST $url');
    debugPrint('[API] Headers: $headers');
    debugPrint('[API] Body: $body');
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create project: ${response.statusCode} ${response.body}');
    }
  }

  static Future<Project> updateProjectStage(int projectId, String stage) async {
    final url = '$baseUrl/projects/update-stage/$projectId?stage=${Uri.encodeComponent(stage)}';
    final headers = await _getHeaders();
    debugPrint('[API] PUT $url');
    final response = await http.put(Uri.parse(url), headers: headers);
    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');
    if (response.statusCode == 200) {
      return Project.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update project stage: ${response.statusCode} ${response.body}');
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
    } else if (response.statusCode == 409) {
      // Conflict: EOI already exists
      throw Exception('EOI already submitted for this project');
    } else {
      throw Exception('Failed to submit EOI: ${response.statusCode}');
    }
  }

  static Future<bool> checkEOIExists(int investorId, int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/eois/check/$investorId/$projectId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['exists'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint("Error checking EOI existence: $e");
      return false;
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
