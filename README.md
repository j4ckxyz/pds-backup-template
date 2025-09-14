# bsky-backup-template

Template repository for setting up a new ATProto repository or PDS backup using GitHub Actions.

The contents of the repository will allow an [adversarial PDS
migration](https://www.da.vidbuchanan.co.uk/blog/adversarial-pds-migration.html)
in case the original PDS disappears.

> [!CAUTION]
> Although all data backed up by this script is public, deleted posts and blobs
> will remain in the git history after being deleted from Bluesky.

> [!NOTE]
> Blobs are stored in git.
> Accounts with large or many videos may exceed GitHub limits.

This is based on https://github.com/simonw/git-scraper-template by Simon Willison.

## How to use this

<img width="754" height="390" alt="image" src="https://github.com/user-attachments/assets/f0f1a19c-d34d-49a6-bfe2-51ec49517c6f" />

1. Visit https://github.com/FiloSottile/bsky-backup-template/generate.

2. Pick a name for your new repository, then type either the Bluesky handle
   (including the @, e.g. `@filippo.abyssdomain.expert`) or DID (e.g.
   `did:plc:x2nsupeeo52oznrmplwapppl`), **or** the URL of a PDS you
   self‑host (e.g. `https://pds.example.com`) in the **description field**.

3. Click **Create repository from template**.

Your new repository will be created, and a script will run which will do the following:

- Add a `run.sh` script to your repository which uses
  [`goat`](https://pkg.go.dev/github.com/bluesky-social/indigo/cmd/goat) to
  backup the target specified in the description field:
  - `./backup.sh` for single accounts.
  - `./backup_pds.sh` for an entire PDS. This exports all repositories on
    the PDS, keeps the last seven daily CAR snapshots per user, and exports
    all blobs once a month (skipping on failure).
- Run that `./run.sh` command and commit the result to the repository.
- Configure a schedule to run this script once every 24 hours.
