class Student < ApplicationRecord
  belongs_to :course
  def credential
    Credential.find(self.credential_id)
  end

  def add_credential(email, password, password_confirmation)
    @credential = Credential.new({email: email, password: password, password_confirmation: password_confirmation})
    if @credential.save
      self.credential_id = @credential.id
    else
      @credential.errors
    end
  end

  def delete_credential
    @cred = Credential.find(self.credential_id)
    @cred.destroy
  end
end
