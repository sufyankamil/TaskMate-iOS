import '../report/screens/show_report.dart';
import '../task/screen/add_task.dart';
import '../task/screen/show_all_task.dart';

class Constants {
  Constants._privateConstructor();

  static final Constants _instance = Constants._privateConstructor();

  static Constants get instance => _instance;

  static const String ok = "Ok";

  // firebase constants
  static const usersCollection = 'users';
  static const communitiesCollection = 'communities';
  static const tasksCollection = 'tasks';
  static const commentsCollection = 'comments';

  static const tabWidgets = [
    ShowAllTask(),
    AddTask(),
    ShowReport(),
  ];

  // Repositories constants
  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';
  static const avatarDefault =
      'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2';

  // Constants for LoginScreen
  static const String loginScreenRoute = '/login';
  static const String loginText = 'Login';
  static const String logoImage = 'assets/images/logo.png';
  static const loginEmote = 'assets/images/loginEmote.png';
  static const String googleImage = 'assets/images/google.png';
  static const String skipText = 'Skip';
  static const String diveInText = 'Instantly dive in to add your first task';
  static const String continueWithGoogle = 'Continue with Google';
  static const String defaultEmail = 'guest@gmail.com';

  // Constants for profile
  static const String profileScreenRoute = '/profile';
  static const String mailPath = 'taskmatee@gmail.com';
  static const String mailScheme = 'mailto';
  static const String mailSubject = 'Help in Task Mate App';
  static const String mailError = 'Error';
  static const String mailErrorContent =
      'Could not open Gmail app. Make sure you have Gmail app installed.';
  static const String upgradeToPremium = 'Upgrade to Premium';
  static const String help = 'Help';
  static const String settings = 'Settings';
  static const String logout = 'Logout';
  static const String myProfile = 'My Profile';
  static const String suggestions = 'Suggestions';
  static const String suggestionsContent =
      'You will soon be able to send us suggestions.';
  static const String switchTheme = 'Switch Theme';
}
