import 'package:cconnect/data/models/resourceItem.dart';

abstract class IResourceRepository {
  Future<ResourceItem> uploadResource(ResourceItem item, List<int>? fileBytes);
  Future<ResourceItem?> getById(String id);
  Future<List<ResourceItem>> listPendingApproval();
  Future<List<ResourceItem>> listByOwner(String ownerId);
  Future<void> approveResource(String id, bool approved);
}
