import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import 'package:demande_admission/screens/home_screen.dart';
import 'package:demande_admission/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
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
                  'Connexion',
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
                                  : Text('Se connecter'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Lien inscription
                TextButton(
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  ),
                  child: Text(
                    'Pas de compte ? Créez-en un',
                    style: TextStyle(color: Colors.teal.shade700),
                  ),
                ),
                SizedBox(height: 24),

                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OU'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 24),

                // Bouton Google
                OutlinedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  label: Text(
                    'Continuer avec Google',
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
        await AuthService().signInWithEmail(
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