// File: config/scripts/second_level_domain.groovy
def name = doc['dns.question.name.raw'].value
if (name == null) { return null }

def sld = null
def labels = name.tokenize('.');
if (labels.size() >= 2) {
    sld = labels.subList(labels.size() - 2, labels.size()).join('.') + '.'
}

return sld
