# Beast Saver Sync

Syncs installed custom beatsaber songs with BeastSaber bookmarks.

* * *

After running into multiple issues with with BeatDrop, SyncSaberService, and
others tools - ended up rolling my own.

## Installation

```bash
git clone https://github.com/drn/beast-saber-sync.git ~/sync 2>/dev/null
cd ~/sync
git fetch
git reset --hard origin/master
bundle
./sync
```

## References

* [SyncSaberService](https://github.com/Zingabopp/SyncSaberService/blob/master/SyncSaberLib/SyncSaber.cs)
* [Beat Saver API](https://beatsaver.com/api/maps/by-hash/3a49f1b40044ba90eb27963c29121537cec28a44)
* [Beast Saber API](https://bsaber.com/wp-json/bsaber-api/songs/?bookmarked_by=sanguinerane)
