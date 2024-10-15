# frozen_string_literal: true

class PrescriptionsController < ApplicationController
  include PrescriptionsHelper

  def new
    @doctors = [User.default_doctor]
    @patients = [User.current]
    @prescription = Prescription.new
  end

  def show
    @prescription = Prescription.find_by(id: params[:id])
    return unless @prescription.nil?

    render plain: 'Not Found', status: :not_found
  end

  def create
    @doctors = [User.default_doctor]
    @patients = [User.current]
    @prescription = Prescription.new(prescription_params)
    @prescription.issued_at = DateTime.now

    begin
      if User.exists?(id: prescription_params[:doctor_id]) && User.exists?(id: prescription_params[:patient_id])
        if @prescription.save
          redirect_to inbox_path(id: User.default_doctor), notice: 'Prescription was successfully created.'
        else
          flash.now[:alert] = @prescription.errors.full_messages.join(', ')
          render :new
        end
      else
        flash.now[:alert] = 'Doctor or patient does not exist.'
        render :new
      end
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "Error creating prescription: #{e.message}"
      render :new
    rescue StandardError => e
      flash.now[:alert] = "An unexpected error occurred: #{e.message}"
      render :new
    end
  end

  def index
    @prescriptions = Prescription.where(doctor_id: User.default_doctor)
  end

  private

  def prescription_params
    params.require(:prescription).permit(:doctor_id, :patient_id, :dosage, :medication, :valid_until, :notes)
  end
end
