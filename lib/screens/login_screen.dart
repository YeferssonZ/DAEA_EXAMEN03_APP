import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recomendator_app/screens/video_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    _passwordVisibilityController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    Navigator.pushNamed(context, '/register');
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.103:5283/api/Auth/login'),
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
          MaterialPageRoute(builder: (context) => VideoScreen(username: username,userId: userId,)),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre de usuario o contraseña incorrectos')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el inicio de sesión')),
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
              const SizedBox(height: 24.0),
              _buildLoginButton(),
              const SizedBox(height: 16.0),
              _buildRegisterRow(),
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
        'assets/images/image3.png',
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
                turns: Tween(begin: 0.0, end: 0.5).animate(_passwordVisibilityController),
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      child: const Text('Iniciar sesión'),
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

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¿No tienes cuenta?', style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: _handleRegister,
          child: const Text('Regístrate', style: TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }
}
