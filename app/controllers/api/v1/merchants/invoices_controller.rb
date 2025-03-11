class Api::V1::Merchants::InvoicesController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = merchant.invoices.includes(:coupon)

    invoices = if params[:status].present?
                  merchant.invoices_filtered_by_status(params[:status])
                else
                  merchant.invoices
                end
      render json: InvoiceSerializer.new(invoices), status: :ok
      
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Merchant not found" }, status: :not_found
  end
end