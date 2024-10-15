# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :set_prescription

  def admin_request_failure
    mail_to_admin('user.mailer.reissue_request_failed')
  end

  def admin_reissue_success
    mail_to_admin('user.mailer.reissue_successful')
  end

  def patient_reissue_success
    mail_to_patient('user.mailer.reissue_successful')
  end

  def patient_reissue_failure
    mail_to_patient('user.mailer.reissue_request_failed')
  end

  private

  def set_prescription
    @prescription = params[:prescription]
  end

  def mail_to_admin(subject_key)
    mail(to: User.default_admin.email, subject: t(subject_key))
  end

  def mail_to_patient(subject_key)
    mail(to: @prescription.patient.email, subject: t(subject_key))
  end
end
