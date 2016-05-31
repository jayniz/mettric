# So other people can recognize mettric errors
class Mettric::Error < StandardError; end

class Mettric::CouldNotStartWorkerThread < Mettric::Error; end
class Mettric::MissingAppName            < Mettric::Error; end
class Mettric::MissingHostName           < Mettric::Error; end
class Mettric::MissingService            < Mettric::Error; end
