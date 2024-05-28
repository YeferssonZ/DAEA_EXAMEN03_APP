import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recomendator_app/screens/video_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late final AnimationController _passwordVisibilityController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisibilityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordVisibilityController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.pushNamed(context, '/login');
  }

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.106:5283/api/Auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nombre': username,
          'contrasena': password,
        }),
      );

      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String userId = responseData['id'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VideoScreen(username: username, userId: userId,)),
        );
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre de usuario ya está en uso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el registro')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al realizar la solicitud: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLogo(),
              const SizedBox(height: 24.0),
              _buildUsernameField(),
              const SizedBox(height: 16.0),
              _buildPasswordField(),
              const SizedBox(height: 16.0),
              _buildConfirmPasswordField(),
              const SizedBox(height: 24.0),
              _buildRegisterButton(),
              const SizedBox(height: 16.0),
              _buildLoginRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: Image.asset(
        'assets/images/image2.png',
        height: 250.0,
        width: 250.0,
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey[800],
        hintText: 'Nombre de usuario',
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      style: const TextStyle(color: Colors.white),
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey[800],
        hintText: 'Contraseña',
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.white70,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
            if (_isPasswordVisible) {
              _passwordVisibilityController.forward();
            } else {
              _passwordVisibilityController.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _passwordVisibilityController,
            builder: (context, child) {
              return RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5)
                    .animate(_passwordVisibilityController),
                child: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      style: const TextStyle(color: Colors.white),
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey[800],
        hintText: 'Confirmar Contraseña',
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.white70,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
            if (_isPasswordVisible) {
              _passwordVisibilityController.forward();
            } else {
              _passwordVisibilityController.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _passwordVisibilityController,
            builder: (context, child) {
              return RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5)
                    .animate(_passwordVisibilityController),
                child: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _register,
      child: const Text('Registrar'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 16.0,
        ),
      ),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¿Ya tienes cuenta?',
            style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: _handleLogin,
          child: const Text('Inicia Sesión aquí',
              style: TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }
}
