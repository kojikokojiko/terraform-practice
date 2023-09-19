resource "aws_lb" "example"{
    name = "example"
    load_balancer_type = "application"
    # ALBがインターネット向けなのかVPC向けなのかを指定する
    internal = false
    idle_timeout = 60
    # 削除保護
    enable_deletion_protection = false
    subnets=[
        aws_subnet.public_0.id,
        aws_subnet.public_1.id,
    ]
    access_logs{
        bucket = aws_s3_bucket.alb_log.id
        enabled = true
    }

    security_groups = [
        module.http_sg.security_group_id,
        module.https_sg.security_group_id,
        module.http_redirect_sg.security_group_id,
    ]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"

    default_action {
        # 固定のHTTPレスポンスを返す
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "これはHTTPのレスポンスです"
            status_code = "200"
        }
    }
}



resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.example.arn
    port = 443
    protocol = "HTTPS"
    certificate_arn = aws_acm_certificate.example.arn
#    セキュリティポリシー
    ssl_policy = "ELBSecurityPolicy-2016-08"

    default_action {
        # 固定のHTTPレスポンスを返す
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "これはHTTPSのレスポンスです"
            status_code = "200"
        }
    }

    depends_on = [
        aws_acm_certificate_validation.example

    ]
}



resource "aws_lb_listener" "redirect_http_to_https" {
    load_balancer_arn = aws_lb.example.arn
    port = 8080
    protocol = "HTTP"

    default_action {
        # 固定のHTTPレスポンスを返す
        type = "redirect"
        redirect {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

output "alb_dns_name" {
    value = aws_lb.example.dns_name
}


resource "aws_lb_target_group" "example" {
    name = "example"
#    EC2Fargateではipを選択する
    target_type = "ip"
#    ルーティング先
    vpc_id = aws_vpc.example.id
    port = 80
    protocol = "HTTP"
    deregistration_delay = 300
    # ヘルスチェック
    health_check {
        path = "/"
        healthy_threshold = 5
        unhealthy_threshold = 2
        timeout = 5
        interval = 30
        matcher = 200
        port = "traffic-port"
        protocol = "HTTP"
    }
    depends_on = [aws_lb.example]
}



resource "aws_lb_listener_rule" "example"{
    listener_arn = aws_lb_listener.https.arn
#    優先順位　数字が小さいほど優先順位が高い
    priority = 100
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.example.arn
    }
    condition {
        path_pattern {
            values = ["/*"]
        }
    }
}


