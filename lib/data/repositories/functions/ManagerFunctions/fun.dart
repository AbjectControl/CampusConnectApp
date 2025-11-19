import 'package:cconnect/data/models/AdminAction.dart';
import 'package:cconnect/data/models/announcement.dart';
import 'package:cconnect/data/models/discussionPost.dart';
import 'package:cconnect/data/models/eventItem.dart';
import 'package:cconnect/data/models/friendshipModel.dart';
import 'package:cconnect/data/models/groupCommunity.dart';
import 'package:cconnect/data/models/mentorProfile.dart';
import 'package:cconnect/data/models/message.dart';
import 'package:cconnect/data/models/paymentRecord.dart';
import 'package:cconnect/data/models/resourceItem.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iadmin.dart';
import 'package:cconnect/data/repositories/interfaces/iannouncement.dart';
import 'package:cconnect/data/repositories/interfaces/iauth.dart';
import 'package:cconnect/data/repositories/interfaces/ichat.dart';
import 'package:cconnect/data/repositories/interfaces/ievent.dart';
import 'package:cconnect/data/repositories/interfaces/iforum.dart';
import 'package:cconnect/data/repositories/interfaces/ifriendship.dart';
import 'package:cconnect/data/repositories/interfaces/igroup.dart';
import 'package:cconnect/data/repositories/interfaces/imentor.dart';
import 'package:cconnect/data/repositories/interfaces/ipayment.dart';
import 'package:cconnect/data/repositories/interfaces/irecommendation.dart';
import 'package:cconnect/data/repositories/interfaces/iresource.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';
import 'package:cconnect/utils/constraints/enums.dart';

// class AuthManager {
//   final IAuthRepository authRepo;
//   final IUserRepository userRepo;

//   AuthManager({required this.authRepo, required this.userRepo});

//   Future<User> signInWithGoogle() async {
//     final user = await authRepo.signInWithGoogle();
//     // ensure user exists in app DB
//     try {
//       final existing = await userRepo.getById(user.id);
//       return existing;
//     } catch (e) {
//       // new user -> create
//       return userRepo.create(user);
//     }
//   }

//   Future<void> signOut() => authRepo.signOut();

//   Future<User?> currentUser() => authRepo.currentUser();
// }
class AuthManager {
  final IAuthRepository authRepo;
  final IUserRepository userRepo;

  AuthManager({required this.authRepo, required this.userRepo});

  Future<User> signIn(String email, String password) async {
    final user = await authRepo.signInWithEmail(email, password);

    try {
      return await userRepo.getById(user.id);
    } catch (_) {
      return userRepo.create(user);
    }
  }

  Future<User> signUp(String email, String password) async {
    final user = await authRepo.signUpWithEmail(email, password);
    return userRepo.create(user);
  }

  Future<void> signOut() => authRepo.signOut();
}

class MentorManager {
  final IMentorRepository repo;
  final IUserRepository userRepo;
  MentorManager({required this.repo, required this.userRepo});

  Future<void> registerAsMentor(String userId, MentorProfile profile) async {
    // simple validation
    final user = await userRepo.getById(userId);
    if (user.role == UserRole.student || user.role == UserRole.mentor) {
      await repo.registerMentor(profile);
    } else {
      throw Exception('Only students/mentors can register as mentor');
    }
  }

  Future<void> approveMentor(String userId, bool approve) =>
      repo.approveMentor(userId, approve);
}

class ResourceManager {
  final IResourceRepository repo;
  ResourceManager({required this.repo});
  Future<ResourceItem> uploadResource(ResourceItem item, List<int>? bytes) =>
      repo.uploadResource(item, bytes);
  Future<void> approveResource(String id, bool approved) =>
      repo.approveResource(id, approved);
}

class ForumManager {
  final IForumRepository repo;
  ForumManager({required this.repo});
  Future<DiscussionPost> createPost(DiscussionPost p) => repo.createPost(p);
  Future<void> reply(String postId, DiscussionPost reply) =>
      repo.replyToPost(postId, reply);
}

class EventManager {
  final IEventRepository repo;
  EventManager({required this.repo});
  Future<EventItem> createEvent(EventItem e) => repo.createEvent(e);
  Future<void> joinEvent(String eventId, String userId) =>
      repo.joinEvent(eventId, userId);
}

class NetworkingManager {
  final IFriendshipRepository repo;
  NetworkingManager({required this.repo});
  Future<Friendship> sendFriendRequest(String fromId, String toId) =>
      repo.sendRequest(fromId, toId);
  Future<void> respondToFriendRequest(String id, bool accept) =>
      repo.respondToRequest(id, accept);
}

class GroupManager {
  final IGroupRepository repo;
  GroupManager({required this.repo});
  Future<GroupCommunity> createGroup(GroupCommunity g) => repo.createGroup(g);
  Future<void> joinGroup(String groupId, String userId) =>
      repo.joinGroup(groupId, userId);
}

class AnnouncementManager {
  final IAnnouncementRepository repo;
  AnnouncementManager({required this.repo});
  Future<Announcement> create(Announcement a) => repo.createAnnouncement(a);
}

class ChatManager {
  final IChatRepository chatRepo;
  ChatManager({required this.chatRepo});
  Future<void> send(Message m) => chatRepo.sendMessage(m);
  Stream<List<Message>> messagesFor(String conversationId) =>
      chatRepo.subscribeToMessages(conversationId);
  Future<void> markRead(
    String conversationId,
    String messageId,
    String userId,
  ) => chatRepo.markRead(conversationId, messageId, userId);
}

class PaymentManager {
  final IPaymentRepository repo;
  PaymentManager({required this.repo});
  Future<PaymentRecord> initiatePayment(PaymentRecord p) =>
      repo.createPayment(p);
  Future<void> updatePayment(String id, PaymentStatus status) =>
      repo.updatePaymentStatus(id, status);
}

class AdminManager {
  final IAdminRepository repo;
  AdminManager({required this.repo});
  Future<void> takeAction(AdminAction a) => repo.takeAction(a);
}

class RecommendationManager {
  final IRecommendationEngine engine;
  RecommendationManager({required this.engine});
  Future<List<String>> recommendResources(String userId) =>
      engine.recommendResourcesForUser(userId);
  Future<List<String>> recommendMentors(String userId) =>
      engine.recommendMentorsForUser(userId);
}
