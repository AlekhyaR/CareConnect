# frozen_string_literal: true

class PatientsController < ApplicationController
  def dashboard
    @prescriptions = Prescription.where(patient: User.current)
  end

  def lost_script
    prescription = Prescription.find(params[:prescription_id])

    # Enqueue the job to handle the request
    LostScriptRequestJob.perform_later(prescription.id)

    # Redirect with a message indicating that the request has been submitted
    redirect_to patient_dashboard_path(prescription.patient.id),
                notice: I18n.t('user.patient.lost_script.dashboard_prescription_status')
  end
end
