import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _OtpBottomSheet extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final FirebaseAuth auth;
  final VoidCallback onVerified;

  const _OtpBottomSheet({
    required this.verificationId,
    required this.phoneNumber,
    required this.auth,
    required this.onVerified,
  });

  @override
  State<_OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<_OtpBottomSheet> {
  late final TextEditingController otpController;

  bool verifying = false;
  bool obscureOtp = true;

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      _showError('Enter the 6-digit OTP.');
      return;
    }

    setState(() {
      verifying = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

    await widget.auth.signInWithCredential(credential);

if (!mounted) return;

// Close OTP sheet
Navigator.of(context).pop();

// Open Profile Screen
widget.onVerified();

// LoginScreen se ProfileScreen par jao
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => const ProfileScreen(),
  ),
);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        verifying = false;
      });

      _showError(_firebaseError(e));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        verifying = false;
      });

      _showError(
        'Unable to verify OTP. Please try again.',
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check and try again.';

      case 'session-expired':
        return 'OTP expired. Please request a new OTP.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet.';

      default:
        return e.message ??
            'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            14,
            24,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF6C63FF),
                  size: 32,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'We sent a 6-digit OTP to\n${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: obscureOtp,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureOtp = !obscureOtp;
                      });
                    },
                    icon: Icon(
                      obscureOtp
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),

                  filled: true,
                  fillColor: const Color(0xFFF7F8FC),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C63FF),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: verifying ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: verifying
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: verifying
                    ? null
                    : () {
                        Navigator.of(context).pop(true);
                      },
                child: const Text(
                  'Change phone number',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // REAL FIREBASE PHONE AUTHENTICATION
  // ============================================================

  Future<void> continueWithPhone() async {
    final phone = phoneController.text.trim();

    if (phone.length != 10) {
      _showMessage(
        'Please enter a valid 10-digit mobile number.',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final fullPhoneNumber = '+91$phone';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);

            if (!mounted) return;

            setState(() {
              isLoading = false;
            });

            _showMessage('Phone verified successfully!');
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;

            setState(() {
              isLoading = false;
            });

            _showMessage(
              _firebaseError(e),
              isError: true,
            );
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showMessage(
            _firebaseError(e),
            isError: true,
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          _showOtpDialog(
            verificationId: verificationId,
            phoneNumber: fullPhoneNumber,
            resendToken: resendToken,
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // Firebase keeps the verification ID available
          // for manual OTP verification.
        },

        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }

 Future<void> _showOtpDialog({
  required String verificationId,
  required String phoneNumber,
  int? resendToken,
}) async {
  await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (sheetContext) {
     return _OtpBottomSheet(
  verificationId: verificationId,
  phoneNumber: phoneNumber,
  auth: _auth,
  onVerified: () {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  },
);
    },
  );
}

  // void _showOtpDialog({
  //   required String verificationId,
  //   required String phoneNumber,
  //   int? resendToken,
  // }) {
  //   final otpController = TextEditingController();
  //   bool verifying = false;
  //   bool obscureOtp = true;

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setModalState) {
  //           Future<void> verifyOtp() async {
  //             final otp = otpController.text.trim();

  //             if (otp.length != 6) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                   content: Text('Enter the 6-digit OTP.'),
  //                 ),
  //               );
  //               return;
  //             }

  //             setModalState(() {
  //               verifying = true;
  //             });

  //             try {
  //               final credential = PhoneAuthProvider.credential(
  //                 verificationId: verificationId,
  //                 smsCode: otp,
  //               );

  //               await _auth.signInWithCredential(credential);

  //               if (!context.mounted) return;

  //               Navigator.pop(context);

  //               _showMessage(
  //                 'Welcome to CareerSaathi 🎉',
  //               );

  //               // TODO:
  //               // Navigate to Home/Profile setup here.
  //             } on FirebaseAuthException catch (e) {
  //               setModalState(() {
  //                 verifying = false;
  //               });

  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text(_firebaseError(e)),
  //                 ),
  //               );
  //             }
  //           }

  //           return Padding(
  //             padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom,
  //             ),
  //             child: Container(
  //               padding: const EdgeInsets.fromLTRB(
  //                 24,
  //                 14,
  //                 24,
  //                 30,
  //               ),
  //               decoration: const BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.vertical(
  //                   top: Radius.circular(30),
  //                 ),
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Container(
  //                     width: 45,
  //                     height: 5,
  //                     decoration: BoxDecoration(
  //                       color: Colors.black12,
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),

  //                   const SizedBox(height: 25),

  //                   Container(
  //                     width: 62,
  //                     height: 62,
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF6C63FF).withOpacity(.12),
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: const Icon(
  //                       Icons.verified_user_rounded,
  //                       color: Color(0xFF6C63FF),
  //                       size: 32,
  //                     ),
  //                   ),

  //                   const SizedBox(height: 18),

  //                   const Text(
  //                     'Verify your number',
  //                     style: TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color(0xFF171923),
  //                     ),
  //                   ),

  //                   const SizedBox(height: 7),

  //                   Text(
  //                     'We sent a 6-digit OTP to\n$phoneNumber',
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.grey,
  //                       height: 1.5,
  //                     ),
  //                   ),

  //                   const SizedBox(height: 24),

  //                   TextField(
  //                     controller: otpController,
  //                     keyboardType: TextInputType.number,
  //                     maxLength: 6,
  //                     obscureText: obscureOtp,
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: 8,
  //                     ),
  //                     decoration: InputDecoration(
  //                       counterText: '',
  //                       hintText: '••••••',
  //                       suffixIcon: IconButton(
  //                         onPressed: () {
  //                           setModalState(() {
  //                             obscureOtp = !obscureOtp;
  //                           });
  //                         },
  //                         icon: Icon(
  //                           obscureOtp
  //                               ? Icons.visibility_outlined
  //                               : Icons.visibility_off_outlined,
  //                         ),
  //                       ),
  //                       filled: true,
  //                       fillColor: const Color(0xFFF7F8FC),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(16),
  //                         borderSide: BorderSide.none,
  //                       ),
  //                       focusedBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(16),
  //                         borderSide: const BorderSide(
  //                           color: Color(0xFF6C63FF),
  //                           width: 1.5,
  //                         ),
  //                       ),
  //                     ),
  //                   ),

  //                   const SizedBox(height: 20),

  //                   SizedBox(
  //                     width: double.infinity,
  //                     height: 55,
  //                     child: ElevatedButton(
  //                       onPressed: verifying ? null : verifyOtp,
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xFF6C63FF),
  //                         foregroundColor: Colors.white,
  //                         elevation: 0,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(16),
  //                         ),
  //                       ),
  //                       child: verifying
  //                           ? const SizedBox(
  //                               width: 23,
  //                               height: 23,
  //                               child: CircularProgressIndicator(
  //                                 strokeWidth: 2.5,
  //                                 color: Colors.white,
  //                               ),
  //                             )
  //                           : const Text(
  //                               'Verify & Continue',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                     ),
  //                   ),

  //                   const SizedBox(height: 14),

  //                   TextButton(
  //                     onPressed: verifying
  //                         ? null
  //                         : () {
  //                             Navigator.pop(context);
  //                             continueWithPhone();
  //                           },
  //                     child: const Text(
  //                       'Change phone number',
  //                       style: TextStyle(
  //                         color: Color(0xFF6C63FF),
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   ).whenComplete(() {
  //     otpController.dispose();
  //   });
  // }

  // ============================================================
  // FIREBASE ERROR HANDLING
  // ============================================================

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later.';

      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check and try again.';

      case 'session-expired':
        return 'OTP expired. Please request a new OTP.';

      case 'network-request-failed':
        return 'Network error. Please check your internet.';

      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 30,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Animated logo
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.7,
                      end: 1.0,
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7C4DFF),
                            Color(0xFF5E35B1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF)
                                .withOpacity(.25),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'CareerSaathi',
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF171923),
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Your career. Your path. Your future.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 48),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome back 👋',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171923),
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sign in to continue your career journey.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Google button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        _showMessage(
                          'Google Sign-In will be connected next.',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFE1E3EA),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'G',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                         SizedBox(width: 11),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF252733),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF30313D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Enter your mobile number',
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: Color(0xFF6C63FF),
                      ),
                      prefixText: '+91  ',
                      prefixStyle: const TextStyle(
                        color: Color(0xFF30313D),
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 17,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFE1E3EA),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C63FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : continueWithPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFB8B3F2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Send OTP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 21,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secured by Firebase Authentication',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'By continuing, you agree to our Terms & Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}