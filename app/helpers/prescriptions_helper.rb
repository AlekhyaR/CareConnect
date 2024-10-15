# frozen_string_literal: true

module PrescriptionsHelper
  def format_date(date)
    date&.strftime('%B %d, %Y')
  end

  def render_prescription_action(prescription)
    if prescription.active?
      button_to t('messages.show.request_new'),
                lost_script_patient_path(prescription.patient, prescription_id: prescription.id),
                method: :post,
                data: { confirm: t('user.patient.prescription.confirm_reissue') },
                class: 'btn btn-warning mt-2'
    else
      content_tag(:p, content_tag(:strong, prescription.status))
    end
  end
end
