# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:inbox) { create(:inbox, user:) }
  let(:outbox) { create(:outbox, user:) }
  let(:patient) { create(:user, :patient) }
  let(:doctor) { create(:user, :doctor) }
  let(:doctor_outbox) { create(:outbox, user: doctor) }
  let(:patient_inbox) { create(:inbox, user: patient) }
  let(:patient_outbox) { create(:outbox, user: patient) }
  let(:admin_inbox) { create(:inbox, user: User.default_admin) }
  let!(:message) { create(:message, inbox:, outbox:, body: 'Hello World') }

  describe 'GET #show' do
    context 'when message exists' do
      it 'marks the message as read' do
        get :show, params: { id: message.id }
        message.reload
        expect(message.read).to be true
      end

      it 'renders the show template' do
        get :show, params: { id: message.id }
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new message to @message' do
      get :new
      expect(assigns(:message)).to be_a_new(Message)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when creating a new message' do
      it 'creates a new message successfully' do
        expect do
          post :create, params: { message: { body: 'New Message', inbox_id: inbox.id, outbox_id: outbox.id } }
        end.to change(Message, :count).by(1)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('messages.create.success_notice'))
      end
    end

    context 'when creating a reply' do
      let(:default_admin) { create(:user, :admin) }

      before do
        allow(User).to receive(:default_admin).and_return(default_admin)
      end
      
      it 'creates a reply to an existing message' do
        reply = create(:message, inbox: patient_inbox, outbox: doctor_outbox, body: 'Original Message')
        reply.update(created_at: 2.weeks.ago)

        expect do
          post :create,
               params: { message: { body: 'Reply Message', reply_to_id: reply.id, inbox_id: admin_inbox.id,
                                    outbox_id: patient_outbox.id } }
        end.to change(Message, :count).by(1)

        reply.reload
        expect(reply.replied).to be true
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when message creation fails' do
      before do
        invalid_message = Message.new(body: '')
        invalid_message.valid?

        allow(Message).to receive(:create_message).and_return(invalid_message)

        post :create, params: { message: { body: '' } }
      end

      it 'renders the new template with an error message' do
        expect(response).to render_template(:new)

        expect(flash.now[:alert]).to eq(I18n.t('messages.create.error_notice',
                                               message: "Inbox must exist, Outbox must exist, Body can't be blank"))
      end
    end
  end

  describe 'GET #index' do
    it 'assigns the first message to @messages' do
      get :index
      expect(assigns(:messages)).to eq([Message.first])
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
