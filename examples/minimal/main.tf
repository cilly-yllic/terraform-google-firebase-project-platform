module "firebase_platform" {
  source = "../.."

  project_id = "my-minimal-project"
  region     = "asia-northeast1"

  firebase  = true
  firestore = true
}
