package supervise

import (
	"context"

	"github.com/coreos/etcd/clientv3"
	"github.com/gocardless/pgsql-cluster-manager/etcd"
	"github.com/gocardless/pgsql-cluster-manager/pacemaker"
	"github.com/Sirupsen/logrus"
)

func Cluster(
	ctx context.Context, // supervise only until the context expires
	logger *logrus.Logger, // log all output here
	client *clientv3.Client, // watch for changes using this etcd client
	etcdHostKey string, // set the Postgres host at this key
	masterCrmXPath string, // selector into the cib that identifies current master
) {
	// Watch for changes to master node, calling the handler registered on the host key
	crmSub := pacemaker.NewSubscriber(
		pacemaker.WatchNode(etcdHostKey, masterCrmXPath, "uname"),
		pacemaker.WithLogger(logger),
	)

	// We should only update the key if it's changed- Updater provides idempotent updates
	crmSub.AddHandler(etcdHostKey, &etcd.Updater{client})
	crmSub.Start(ctx)
}