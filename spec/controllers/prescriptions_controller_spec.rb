# frozen_string_literal: true

# spec/controllers/prescriptions_controller_spec.rb
require 'rails_helper'

RSpec.describe PrescriptionsController, type: :controller do
  let!(:doctor) { create(:user, :doctor) }
  let!(:patient) { create(:user, :patient) }

  describe 'GET #new' do
    it 'assigns new prescription and renders the new template' do
      get :new
      expect(assigns(:prescription)).to be_a_new(Prescription)
      expect(assigns(:doctors)).to eq([User.default_doctor])
      expect(assigns(:patients)).to eq([User.current])
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #show' do
    context 'when the prescription exists' do
      let!(:prescription) { create(:prescription) }

      it 'assigns the prescription and renders the show template' do
        get :show, params: { id: prescription.id }

        expect(assigns(:prescription)).to eq(prescription)
        expect(response).to render_template(:show)
      end
    end

    context 'when the prescription does not exist' do
      it 'returns a 404 not found status' do
        get :show, params: { id: 999 }
        expect(response.status).to eq(404)
        expect(response.body).to include('Not Found')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        { prescription: { doctor_id: doctor.id, patient_id: patient.id, medication: 'Ibuprofen', dosage: '200mg',
                          valid_until: Time.zone.today + 30.days } }
      end

      it 'creates a new prescription' do
        expect do
          post :create, params: valid_params
        end.to change(Prescription, :count).by(1)
      end

      it 'redirects to the inbox with a success notice' do
        post :create, params: valid_params
        expect(response).to redirect_to(inbox_path(id: doctor))
        expect(flash[:notice]).to eq('Prescription was successfully created.')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { prescription: { doctor_id: nil, patient_id: nil, medication: '', dosage: '', valid_until: nil } }
      end

      it 'does not create a new prescription and renders new template with errors' do
        expect do
          post :create, params: invalid_params
        end.not_to change(Prescription, :count)

        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq('Doctor or patient does not exist.')
      end
    end

    context 'when doctor or patient does not exist' do
      let(:non_existent_user_params) do
        { prescription: { doctor_id: 999, patient_id: 999, medication: 'Ibuprofen', dosage: '200mg',
                          valid_until: Time.zone.today + 30.days } }
      end

      it 'does not create the prescription and renders new template with an error message' do
        post :create, params: non_existent_user_params
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq('Doctor or patient does not exist.')
      end
    end

    context 'when an exception is raised during creation' do
      before do
        allow_any_instance_of(Prescription).to receive(:save).and_raise(StandardError, 'Unexpected error')
      end

      it 'rescues the error and renders the new template with an alert' do
        post :create,
             params: { prescription: { doctor_id: doctor.id, patient_id: patient.id, medication: 'Ibuprofen', dosage: '200mg',
                                       valid_until: Time.zone.today + 30.days } }
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq('An unexpected error occurred: Unexpected error')
      end
    end
  end

  describe 'GET #index' do
    let!(:default_doctor) { User.default_doctor }
    let!(:prescription) { create(:prescription, doctor: default_doctor) }

    it 'assigns prescriptions belonging to the default doctor' do
      get :index

      expect(assigns(:prescriptions)).to eq([prescription])
    end
  end
end
