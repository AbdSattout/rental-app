// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome to Homio';

  @override
  String hello(String name) {
    return 'Hi, $name!';
  }

  @override
  String get welcome_subtitle => 'Find your perfect home';

  @override
  String get get_started => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get logout => 'Logout';

  @override
  String get phone => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get bio => 'Bio';

  @override
  String get idImage => 'ID Image';

  @override
  String get profileImage => 'Profile Image';

  @override
  String get dateOfBirthFormat => 'Date of Birth (YYYY-MM-DD)';

  @override
  String get rent => 'Rent';

  @override
  String get price => 'Price';

  @override
  String get rooms => 'Rooms';

  @override
  String get bath => 'Bathrooms';

  @override
  String get space => 'Area (m²)';

  @override
  String get type => 'Type';

  @override
  String get location => 'Location';

  @override
  String get postDetails => 'Post Details';

  @override
  String get details => 'Details';

  @override
  String get profile => 'Profile';

  @override
  String get hostProfile => 'Host Profile';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get typeHouse => 'House';

  @override
  String get typeApartment => 'Apartment';

  @override
  String get typeVilla => 'Villa';

  @override
  String get typeOffice => 'Office';

  @override
  String get appartments => 'Apartments';

  @override
  String get myApartments => 'My Apartments';

  @override
  String get noAppartments => 'No Apartments';

  @override
  String get publishApartment => 'Publish Apartment';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get becomeHost => 'Become a Host';

  @override
  String get approvalPending =>
      'Your account is under review. You\'ll be able to use full features once approved.';

  @override
  String get approvalRejected => 'Your account was rejected.';

  @override
  String get role => 'Role';

  @override
  String get guest => 'Guest';

  @override
  String get tenant => 'Tenant';

  @override
  String get host => 'Host';

  @override
  String get postHost => 'Host';

  @override
  String get requestingHost => 'Requesting Host Access';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get invalidCredentials => 'Invalid phone number or password';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic (العربية)';

  @override
  String get guestMode => 'You are browsing as a guest';

  @override
  String get account_under_review => 'Your account is under review';

  @override
  String get admin => 'Admin';

  @override
  String get selectAtLeastOnePhoto => 'Please select at least one photo';

  @override
  String get required => 'This field is required';

  @override
  String get notAHost =>
      'Request to become a host in settings to be able to post apartments';

  @override
  String get nothingHere => 'No results found';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get featured => 'Featured';

  @override
  String get gallery => 'Gallery';

  @override
  String get createApartment => 'Create Apartment';

  @override
  String get editApartment => 'Edit Apartment';

  @override
  String get deleteApartment => 'Delete Apartment';

  @override
  String get confirmDeleteApartment =>
      'Are you sure you want to delete this apartment?';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get clear => 'Clear';

  @override
  String get map => 'Map';

  @override
  String get contact => 'Contact';

  @override
  String get deletePost => 'Delete Apartment';

  @override
  String get areYouSureDeletePost =>
      'Are you sure you want to delete this apartment?';

  @override
  String get createANewAccount => 'Create a new account';

  @override
  String get already_have_account => 'Already have an account?';

  @override
  String get dont_have_account => 'Don\'t have an account?';

  @override
  String get sign_up_here => 'Sign up here';

  @override
  String get sign_in_here => 'Sign in here';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get checkYourRequest => 'Please check the info you provided';

  @override
  String get anErrorOccurred => 'An error occurred, please try again';

  @override
  String get signInToYourAccount => 'Sign in to your account';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneMinDigits => 'Phone number must be at least 10 digits';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinCharacters => 'Password must be at least 8 characters';

  @override
  String get minPasswordCharacters => 'Min 8 characters';

  @override
  String get uploadRequiredImages => 'Please upload all required images';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get upload => 'Upload';

  @override
  String get imageTooLarge => 'Image is too large';

  @override
  String get invalidImageType => 'Invalid image type';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get openStreetMapContributors => 'OpenStreetMap Contributors';

  @override
  String get welcome_title => 'Welcome to Homio!';

  @override
  String get welcome_description =>
      'Are you looking for a beautiful\nhome to rent?';

  @override
  String get find_home_title => 'Find your home';

  @override
  String get find_home_description =>
      'Our app makes it easy to find the\nperfect place that matches your\nneeds and lifestyle';

  @override
  String get start_journey_title => 'Start Your Home Journey';

  @override
  String get start_journey_description =>
      'Ready to move into your ideal\nplace ? let\'s go';

  @override
  String get rating => 'Rating';

  @override
  String get ratings => 'ratings';

  @override
  String get ratingSubmitted => 'Rating submitted';

  @override
  String get cannotRate => 'Cannot rate before renting';

  @override
  String get reservations => 'Reservations';

  @override
  String get myReservations => 'My Reservations';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkOut => 'Check Out';

  @override
  String get reserve => 'Reserve';

  @override
  String get reservationSuccess => 'Reservation created successfully';

  @override
  String get reservationConflict => 'Selected dates are already reserved';

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String get canceled => 'Canceled';

  @override
  String get completed => 'Completed';

  @override
  String get noReservations => 'No reservations yet';

  @override
  String get reservationsSection => 'Reservations';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get editReservation => 'Edit Reservation';

  @override
  String get confirmCancelReservation =>
      'Are you sure you want to cancel this reservation?';

  @override
  String get reservationUpdated => 'Reservation updated successfully';

  @override
  String get reservationCanceled => 'Reservation canceled successfully';

  @override
  String get update => 'Update';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get to => 'to';

  @override
  String get manageReservations => 'Manage Reservations';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get updateRequests => 'Update Requests';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get noUpdateRequests => 'No update requests';

  @override
  String get reservationApproved => 'Reservation approved';

  @override
  String get reservationRejected => 'Reservation rejected';

  @override
  String get updateApproved => 'Update approved';

  @override
  String get updateRejected => 'Update rejected';

  @override
  String get confirmApprove => 'Approve this reservation?';

  @override
  String get confirmReject => 'Reject this reservation?';

  @override
  String get confirmApproveUpdate => 'Approve this update request?';

  @override
  String get confirmRejectUpdate => 'Reject this update request?';

  @override
  String get showAll => 'Show All';

  @override
  String get nearYou => 'Near you';

  @override
  String get latestPosts => 'Latest Posts';

  @override
  String get perDay => 'per day';
}
