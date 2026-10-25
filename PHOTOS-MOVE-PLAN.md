# Moving Petra's Photos Library Off the Internal Disk

## Objective

Relocate `/Users/hip/Pictures/Photos Library.photoslibrary` (426 GB, of which 390 GB is `originals`) to an external drive, so that ~426 GB is returned to the internal volume. The library is copied and verified before anything is deleted.

## Why the destination is an external drive, not this repo

The dotfiles repo root, `/Users/suhlig/git/github.com/suhlig/dotfiles`, is on the same APFS volume (`disk3s5`) that is full. Putting the library there would free zero bytes, would not fit in the ~42 GiB currently free, and would pollute a git work tree with 426 GB of binary packages. This document therefore lives at the repo root, and the library goes to an external volume.

## Current state (measured 2026-10-25)

- Internal volume: 926 GiB capacity, 860 GiB used, 42 GiB free.
- Library: 426 GB total; `originals` 390 GB.
- `Optimize Mac Storage`: enabled, but has evicted nothing, including when the disk was down to 1 GiB free. Treat it as non-functional on this machine and do not wait on it.
- iCloud Photos: enabled. The account has a 6 TiB plan with 2.1 TiB used, so quota is not the blocker.
- Backups: no Time Machine destination configured, no external volume attached.
- Petra is logged out, and no Photos processes are running for her account.
- Arq backup agent is active as root and takes an APFS snapshot of the Data volume at the start of every backup run. A snapshot created at 18:58 on 2026-10-25 pinned space belonging to files deleted afterwards, which is why deleting 17 GB returned no free space. Any space-reclaiming step must account for this.

## Prerequisites

- External drive with at least 500 GB free; 1 TB is preferable for headroom. Formatted **APFS** or **Mac OS Extended (Journaled)**, **GUID** partition map, **case-insensitive**. An exFAT or case-sensitive volume will corrupt a Photos library.
- Direct connection (Thunderbolt or USB-C preferred over an unpowered hub).
- Admin password for `sudo`.
- Roughly 1–3 hours for the copy at typical external SSD speeds.

## Steps

### 0. Record the baseline

```sh
df -h /System/Volumes/Data
sudo du -sh "/Users/hip/Pictures/Photos Library.photoslibrary"
sudo du -sh "/Users/hip/Pictures/Photos Library.photoslibrary/originals"
```

Keep these numbers; they are the reference for every later comparison.

### 1. Prepare and mount the drive

In Disk Utility: Erase → **APFS** (or Mac OS Extended, Journaled) → **GUID Partition Map** → case-insensitive. Ensure at least 500 GB free. Note the mount point; this plan assumes `/Volumes/Photos`.

### 2. Confirm nothing is using the library

```sh
ps -Ao user,pid,comm | grep -E 'photolibraryd|PhotoAnalysis'
```

Expect no output for `hip`. If Petra is logged in, quit Photos with ⌘Q and re-check. Never copy or delete a library that `photolibraryd` has open.

### 3. Copy the library

```sh
sudo caffeinate -i ditto "/Users/hip/Pictures/Photos Library.photoslibrary" "/Volumes/Photos/Photos Library.photoslibrary"
```

Use `ditto` rather than a Finder drag: it preserves ACLs, extended attributes, and ownership, all of which a Photos library depends on. `caffeinate -i` prevents sleep for the duration.

### 4. Verify sizes and file counts

Both must match exactly:

```sh
sudo du -sh "/Users/hip/Pictures/Photos Library.photoslibrary" "/Volumes/Photos/Photos Library.photoslibrary"
sudo find "/Users/hip/Pictures/Photos Library.photoslibrary" -type f | wc -l
sudo find "/Volumes/Photos/Photos Library.photoslibrary" -type f | wc -l
```

If either differs, stop and recopy. Do not proceed to deletion.

### 5. Prove the copy actually opens

Log Petra in, quit Photos completely, then hold **⌥ Option** while launching Photos and choose the library on the drive. This also doubles as an integrity check after the recent crash. Confirm:

- the total photo and video count matches her expectation;
- several regular albums and at least one smart album;
- an edited photo still shows its edits;
- a video plays, and a Live Photo works.

### 6. Delete the original and release pinned space

Arq stays running. It snapshots the Data volume at the start of each run and deletes that snapshot when the run finishes, at which point the pinned space is returned automatically.

1. Confirm whether a run is active and whether its snapshot is mounted:

```sh
ps -Ao user,pid,%cpu,comm | grep ArqAgent
mount | grep -i arqagent
diskutil apfs listSnapshots /System/Volumes/Data
```

2. Do not delete a snapshot that a running backup has mounted; wait for the run to finish instead.
3. Only if a snapshot persists while no Arq run is active, delete it by hand:

```sh
sudo diskutil apfs deleteSnapshot disk3s5 -name <snapshot-name>
```

4. Only after step 5 passes, delete the library:

```sh
sudo rm -rf "/Users/hip/Pictures/Photos Library.photoslibrary"
```

5. Confirm the space actually returned:

```sh
df -h /System/Volumes/Data
diskutil apfs listSnapshots /System/Volumes/Data
```

Expected result: ~426 GB freed, leaving roughly 470 GiB free on `disk3s5`. If free space has not moved, a snapshot is still pinning the deleted blocks.

6. Expect free space to dip before it rises. Arq's cache in `/Library/Application Support/ArqAgent` was 17 GB at the time of writing and grows during a run, so a backup in flight can temporarily consume more than the deletion releases.

### 7. Point Photos at the drive copy

In Photos: Settings → General → **Use as System Photo Library**, with the drive copy selected. This prevents Photos from silently creating a new, empty library in `~/Pictures` on the next launch.

### 8. Post-checks

```sh
df -h /System/Volumes/Data
ls -la "/Users/hip/Pictures"
```

`~/Pictures` should no longer contain a `.photoslibrary` bundle unless she intentionally keeps a second library, and free space should be in the 450+ GiB range. If free space has not moved, re-measure `/Users/hip` with `sudo du -sh /Users/hip` to confirm what remains there.

## Rollback

- Before step 6, the original is untouched. To abandon the move, delete the drive copy; nothing else changes.
- After step 6, the library exists on the external drive and in iCloud (iCloud Photos is enabled, 2.1 TiB of 6 TiB used). Restore by copying it back to `/Users/hip/Pictures`.
- If verification in step 4 or 5 fails, do not delete the original. Recopy and re-verify; the original is the only local copy.

## Risks and notes

- Do not attempt to speed this up by pulling data back from iCloud. Deleting the local library with iCloud Photos synced may trigger a full 390 GB re-download if Photos is reopened, which recreates the problem.
- When disabling iCloud Photos for any reason, do not choose "Download originals to this Mac"; that pulls the entire library down.
- The external drive becomes a single point of failure. iCloud is synced storage, not a backup. Once space permits, configure Time Machine to a second drive.
- Keep the drive attached, or remount it before launching Photos. Photos cannot open a library from a disconnected volume.
- Leave `Optimize Mac Storage` off for this arrangement; it has demonstrated no effect here and adds uncertainty.
- Arq's APFS snapshots are the reason a large deletion can appear to free nothing. Whenever free space does not change after deleting data, check `diskutil apfs listSnapshots /System/Volumes/Data` before assuming the delete failed.

## Success criteria

- The 390 GB `originals` tree no longer lives on `disk3s5`.
- Free space on the internal volume is 450 GiB or more.
- Photos opens the drive copy with the full library, albums, edits, and videos intact.
