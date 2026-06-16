part of '../main.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserRole? role;

  @override
  Widget build(BuildContext context) {
    final currentRole = role;
    if (currentRole == null) {
      return LoginPage(
        onLogin: (selectedRole) => setState(() => role = selectedRole),
      );
    }
    return Shell(
      role: currentRole,
      onLogout: () => setState(() => role = null),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final ValueChanged<UserRole> onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserRole selectedRole = UserRole.cashier;
  final email = TextEditingController(text: 'cajero@festcine.bo');
  final password = TextEditingController(text: 'demo123');

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sidebarBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: CardBox(
              title: 'INGRESO FESTCINE',
              subtitle: 'Login de FestCine',
              accent: gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BadgeIcon(Icons.movie_filter, gold)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contrasena'),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.cashier,
                        label: Text('Cajero'),
                        icon: Icon(Icons.point_of_sale_outlined),
                      ),
                      ButtonSegment(
                        value: UserRole.admin,
                        label: Text('Admin'),
                        icon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                    ],
                    selected: {selectedRole},
                    onSelectionChanged: (value) {
                      final role = value.first;
                      setState(() {
                        selectedRole = role;
                        email.text = role == UserRole.cashier
                            ? 'cajero@festcine.bo'
                            : 'admin@festcine.bo';
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => widget.onLogin(selectedRole),
                    icon: const Icon(Icons.login),
                    label: Text(
                      selectedRole == UserRole.cashier
                          ? 'Ingresar como Cajero'
                          : 'Ingresar como Administrador',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cajero: venta de entradas. Admin: agenda, ediciones y reportes del festival.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
