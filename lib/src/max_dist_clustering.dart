import '../google_maps_cluster_manager.dart';
import 'common.dart';

class _MinDistCluster<T extends ClusterItem> {
  final Cluster<T> cluster;
  final double dist;

  _MinDistCluster(this.cluster, this.dist);
}

class DistClusterArgs{
  DistClusterArgs({
    required this.dataset,
    required this.zoomLevel,
    this.epsilon = 1
  });

  List<ClusterItem> dataset; int zoomLevel;double epsilon;
}

class MaxDistClustering<T extends ClusterItem> {
  static List<Cluster<ClusterItem>> _cluster = [];

  ///Threshold distance for two clusters to be considered as one cluster
  final double epsilon;

  MaxDistClustering({
    this.epsilon = 1,
  });

  ///Run clustering process, add configs in constructor
  static Future<List<Cluster<ClusterItem>>> run(DistClusterArgs args) async{

    //initial variables
    List<List<double>> distMatrix = [];
    for (ClusterItem entry1 in args.dataset) {
      distMatrix.add([]);
      _cluster.add(Cluster.fromItems([entry1]));
    }
    bool changed = true;
    while (changed) {
      changed = false;
      for (Cluster<ClusterItem> c in _cluster) {
        _MinDistCluster<ClusterItem>? minDistCluster = getClosestCluster(c, args.zoomLevel);
        if (minDistCluster == null || minDistCluster.dist > args.epsilon) continue;
        _cluster.add(Cluster.fromClusters(minDistCluster.cluster, c));
        _cluster.remove(c);
        _cluster.remove(minDistCluster.cluster);
        changed = true;

        break;
      }
    }
    return _cluster;
  }

  static _MinDistCluster<ClusterItem>? getClosestCluster(Cluster cluster, int zoomLevel) {
    final DistUtils distUtils = DistUtils();
    double minDist = 1000000000;
    Cluster<ClusterItem> minDistCluster = Cluster.fromItems([]);
    for (Cluster<ClusterItem> c in _cluster) {
      if (c.location == cluster.location) continue;
      double tmp =
          distUtils.getLatLonDist(c.location, cluster.location, zoomLevel);
      if (tmp < minDist) {
        minDist = tmp;
        minDistCluster = Cluster<ClusterItem>.fromItems(c.items);
      }
    }
    return _MinDistCluster(minDistCluster, minDist);
  }
}
