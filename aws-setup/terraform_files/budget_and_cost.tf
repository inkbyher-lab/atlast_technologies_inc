resource "aws_budgets_budget" "cost_budget" {
    name = "cost-budget"
    budget_type = "COST"
    time_period_start = "2026-12-15_12:00"
    time_unit = "MONTHLY"
    limit_amount = "100"
    limit_unit  = "USD"

    notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["munacopy@gmail.com"]
  }

}

resource "aws_budgets_budget" "usage_budget"{
    name = "usage-budget"
    budget_type = "USAGE"
    time_period_start = "2026-12-15_12:00"
    time_unit = "MONTHLY"
    limit_amount = "3"
    limit_unit = "GB"
    
    notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["munacopy@gmail.com"]
  }
}

resource "aws_ce_anomaly_monitor" "cost_monitor" {
  name              = "AWSServiceMonitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "anomaly_monitor_subscription" {
  name      = "DAILYSUBSCRIPTION"
  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.cost_monitor.arn
  ]

  subscriber {
    type    = "EMAIL"
    address = "munacopy@gmail.com"
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = ["80"]
    }
  }
}
