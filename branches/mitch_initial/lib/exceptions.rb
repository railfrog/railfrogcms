module RailfrogExceptions
  # Extension Exceptions
  class ExtensionAlreadyInstalledException < RuntimeError; end
  class ExtensionFileMissingException < RuntimeError; end
  class ExtensionNoClassException < RuntimeError; end
  class ExtensionNotInstalledException < RuntimeError; end
  class ExtensionInstallFailureException < RuntimeError; end
  class ExtensionUnknownTypeException < RuntimeError; end
  class ExtensionDoesntExistException < RuntimeError; end
  class ExtensionYAMLDoesntExistException < RuntimeError; end
  
  # Role Permission Exceptions
  class RoleDoesntExistException < RuntimeError; end
  class PermDoesntExistException < RuntimeError; end
  class PermOnlyHasOneTranslationException < RuntimeError; end
  class RolePermDoesntExistException < RuntimeError; end
  class LangDoesntExistException < RuntimeError; end
  
  # User Exceptions
  class UserDoesntExistException < RuntimeError; end
  class InvalidPasswordException < RuntimeError; end
  class NoSessionStoringHashException < RuntimeError; end
  class UserAlreadyHasRoleException < RuntimeError; end
  class UserDoesntHaveRoleException< RuntimeError; end
  
  # Item Exceptions
  class ItemDoesntExistException < RuntimeError; end
  class ItemExtensionDoesntExistException < RuntimeError; end
  class ItemExtensionAlreadyExistsException < RuntimeError; end
  
  # Admin Navigation Exceptions
  class AdminNavDoesntExistException < RuntimeError; end
end