import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(String factoryId, String factoryName) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _factoryIdController = TextEditingController();
  final _factoryNameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '1000');
  String _selectedEnergyType = 'Solar';

  @override
  void dispose() {
    _factoryIdController.dispose();
    _factoryNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_isLogin) {
      // For login, just navigate with factoryId
      final factoryId = _factoryIdController.text.trim();
      if (factoryId.isEmpty) {
        _showError('Please enter your Factory ID');
        return;
      }
      widget.onLogin(factoryId, factoryId);
    } else {
      // For registration, call the API
      final factoryId = _factoryIdController.text.trim();
      final factoryName = _factoryNameController.text.trim();
      final initialBalance = double.tryParse(_initialBalanceController.text) ?? 0;

      if (factoryId.isEmpty || factoryName.isEmpty) {
        _showError('Please fill in all required fields');
        return;
      }

      setState(() => _isLoading = true);

      try {
        await ApiService.registerFactory(
          factoryId: factoryId,
          name: factoryName,
          initialBalance: initialBalance,
          energyType: _selectedEnergyType,
        );

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Factory "$factoryName" registered successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        widget.onLogin(factoryId, factoryName);
      } on ApiException catch (e) {
        _showError(e.message);
      } catch (e) {
        _showError('Connection error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0a0a0a),
              Colors.grey.shade900,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.grey.shade900.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'lib/screens/assets/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Next Gen Power',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Peer-to-Peer Energy Trading Platform',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Tabs
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => _isLogin = true),
                              style: TextButton.styleFrom(
                                backgroundColor: _isLogin
                                    ? Colors.grey.shade800
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => _isLogin = false),
                              style: TextButton.styleFrom(
                                backgroundColor: !_isLogin
                                    ? Colors.grey.shade800
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Register Factory'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Form
                      TextField(
                        controller: _factoryIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Factory ID',
                          hintText: 'e.g., F-001',
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (!_isLogin) ...[
                        TextField(
                          controller: _factoryNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Factory Name',
                            hintText: 'e.g., Solar Factory Alpha',
                            labelStyle: const TextStyle(color: Colors.grey),
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.grey.shade800,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _initialBalanceController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Initial Energy Balance (kWh)',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.shade800,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedEnergyType,
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: Colors.grey.shade800,
                          decoration: InputDecoration(
                            labelText: 'Energy Type',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.shade800,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: ['Solar', 'Wind', 'Hydro', 'Biomass', 'Mixed']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedEnergyType = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLogin
                                ? Colors.blue.shade600
                                : Colors.purple.shade600,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isLogin ? Icons.login : Icons.add_business,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isLogin ? 'Login to Dashboard' : 'Register Factory',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isLogin
                            ? 'Enter your Factory ID to access the dashboard'
                            : 'Register your factory on the blockchain network',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
