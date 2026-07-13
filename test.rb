require "web_function"
require "base64"

pipeline = WebFunction::Pipeline.new("http://localhost:55001/api/process-pipeline")

sdk = WebFunction::Client.from_package_endpoint("http://localhost:55001/api/sdk",
  pipeline: pipeline,
)

merchant = WebFunction::Client.from_package_endpoint("http://localhost:55001/api/merchants",
  bearer_auth: "reservepay_u6BHU4diPq7MVZCUJu7Ppu81nTrfYP1fMYVS",
  pipelined: true,
)

installations = merchant.list_installations
payment_session_id = sdk.select_payment_method(
  merchant_id: "11",
  installation_id: installations[0]["installation_id"],
  amount: 10000,
  currency: "THB",
  payment_method: "PROMPTPAY",
)
payment_id = merchant.initiate_payment_flow(
  amount: 10000,
  currency: "THB",
  capture: true,
  return_url: "https://reservepay.com/",
  payment_session_id: payment_session_id,
)
payment = merchant.find_payment(payment_id: payment_id)

p payment.resolve
p payment_session_id

sleep 1

qr_data = sdk.retrieve_qr_data(
  merchant_id: "11",
  installation_id: installations[0]["installation_id"],
  payment_session_id: payment_session_id,
)

p Base64.decode64(qr_data.resolve)
