resource "aws_kms_key" "example" {
  description = "Example Customer Master Key"
#  自動ローテーション
  enable_key_rotation = true
#  有効化・無効化
  is_enabled = true
#  削除待機期間
  deletion_window_in_days = 30
}


resource "aws_kms_alias" "example" {
  name="alias/example"
  target_key_id =aws_kms_key.example.key_id
}



