import 'package:task_mate/collaboration/screens/session_creation.dart';

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
  static const sessionCollection = 'sessions';

  static const tabWidgets = [
    ShowAllTask(),
    AddTask(),
    TaskCollaboration(),
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
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountContent =
      'Are you sure you want to delete your account?';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String deletingContent =
      'Deleting your account is irreversible and will result in the loss of all your data, including profile information, posts, and any associated content. This action cannot be undone.';
  static const String deleteContent1 =
      '  If you are certain about deleting your account, please keep in mind the following:';
  static const String deleteContent2 =
      '- You will lose access to all features and services associated with your account.';
  static const String deleteContent3 =
      '- Any active subscriptions or memberships will be terminated.';
  static const String deleteContent4 =
      'Your profile will be removed from the app.';
  static const confirmation =
      'To proceed with account deletion, please enter CONFIRM below.';

  static const String deleteAccountSuccess = 'Account deleted successfully';

  // Constants for Show All Tasks
  static const String showAllTaskRoute = '/showAllTask';
  static const String noTaskFound =
      'No task found, Start adding tasks so that you don\'t forget your important tasks';

  // Controllers constants
  static const String taskController = 'TaskController';
  static const String taskAlreadyExists =
      'Task with the same name already exists.';
  static const String taskAddedSuccessfully = 'Task Added Successfully';
  static const String subTaskAdded = 'Sub Task Added Successfully';
  static const String subTaskAlreadyExists =
      'Sub Task with the same name already exists.';
  static const String subTaskDeleted = 'Sub Task Deleted Successfully';
  static const String taskDeleted = 'Task Deleted Successfully';
  static const String activeSession = 'activeSession';
  static const String sessionExpired = 'Session Expired';
  static const String sessionExpiredContent =
      'Your session has expired. Please create a new session to continue.';
  static const String sessionLeft = 'Successfully left the session';
  static const String sessionTaskUpdated =
      'Task Updated Successfully in Session';
  static const String sessionTaskUpdateFailed =
      'Unable to update task this time';

  // Repository Constants
  static const String taskRepository = 'TaskRepository';
  static const String userNotAuth = 'User not authenticated';
  static const String sessionDontExist = 'Session does not exist';
  static const String sessionAlreadyExist = 'Session already exist';
  static const String docNotFound = 'Document not found';

  // Show Task Constants
  static const String addToCollaboration = 'Add to collaborate';
  static const String removeFromCollaboration = 'Remove from collaboration';
  static const String deleteTask = 'Delete Task';
  static const String deleteTaskContent =
      'Are you sure you want to delete this task?';
  static const String deleteTaskConfirm = 'Delete';
  static const String deleteTaskCancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String collaborationConfirmation =
      'Are you sure you want to add this task to sessions to all of your collaborators?';
  static const String unshareTask = 'Task has been unshared';
  static const String shareTask = 'Task has been shared in session';

  // Ongoing task Constants
  static const String onGoingAnimation = 'assets/images/task_animation.json';
  static const String startAddingTask =
      'Start adding task by clicking + ${Constants.bellowText}';
  static const String bellowText = 'button below';
  static const String premiumFeature = 'Premium Feature';
  static const String premiumText =
      'Once you have the premium version, you can share it with your friends.';
  static const String completedTask = 'Completed Task';
  static const String unshare = 'Unshare';
  static const String share = 'Share';
  static const String updateTask = 'Task Updated Successfully';
  static const String undo = 'Undo';
  static const String taskCompleted = 'Mark as Completed';
  static const String editTask = 'Click to edit the task';
}
