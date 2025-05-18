import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import 'package:demande_admission/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.teal.shade700,
                ),
                SizedBox(height: 20),
                
                // Titre
                Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                SizedBox(height: 40),

                // Formulaire
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => 
                                value!.isEmpty ? 'Veuillez entrer un email' : null,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: Icon(Icons.lock, color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => 
                                value!.length < 6 ? '6 caractères minimum' : null,
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _submitForm,
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text('S\'inscrire'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Bouton Google
                OutlinedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  label: Text(
                    'S\'inscrire avec Google',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _signInWithGoogle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService().registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await AuthService().signInWithGoogle();
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())));
    }
  }
}