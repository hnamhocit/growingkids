import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/auth/presentation/widgets/enter/login_form.dart';
import 'package:growingkids/features/auth/presentation/widgets/enter/register_form.dart';

class EnterScreen extends StatefulWidget {
  const EnterScreen({super.key});

  @override
  State<EnterScreen> createState() => _EnterScreenState();
}

class _EnterScreenState extends State<EnterScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isSubmitting = context.select<AuthBloc, bool>(
      (bloc) => bloc.state is AuthLoading,
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.goNamed(RoutesName.tabHome);
          }
          return;
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            // PHẦN 1: ẢNH NỀN VÀ TIÊU ĐỀ
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/enter-background.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHÀO MỪNG ĐẾN VỚI PLANTIFY',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.lerp(cs.primary, Colors.white, 0.4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hãy tìm loại cây mơ ước của bạn',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            height: 1.4,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // PHẦN 2: FORM ĐĂNG NHẬP / ĐĂNG KÝ
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(16),
                // Bọc ScrollView để chống lỗi bàn phím che màn hình
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 16,
                          children: [
                            _isLogin ? const LoginForm() : const RegisterForm(),

                            // MẠNG XÃ HỘI
                            Column(
                              spacing: 16,
                              children: [
                                Row(
                                  spacing: 12,
                                  children: const [
                                    Expanded(child: Divider()),
                                    Text('hoặc tiếp tục với'),
                                    Expanded(child: Divider()),
                                  ],
                                ),

                                Row(
                                  spacing: 16,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            side: BorderSide(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          spacing: 12,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/3840px-Google_%22G%22_logo.svg.png',
                                              width: 20,
                                              height: 20,
                                            ),
                                            Text(
                                              'Google',
                                              style: tt.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF1877F2),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          spacing: 12,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_(2019).png/3840px-Facebook_Logo_(2019).png',
                                              width: 20,
                                              height: 20,
                                            ),
                                            Text(
                                              'Facebook',
                                              style: tt.bodyMedium?.copyWith(
                                                color: const Color(0xFF1877F2),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // NÚT CHUYỂN ĐỔI FORM
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isLogin
                                      ? 'Chưa có tài khoản?'
                                      : 'Đã có tài khoản?',
                                ),
                                TextButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () {
                                          setState(() {
                                            _isLogin = !_isLogin;
                                          });
                                        },
                                  child: Text(
                                    _isLogin ? 'Đăng ký ngay' : 'Đăng nhập',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
