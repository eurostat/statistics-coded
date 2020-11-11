import requests
import json
import sys

class RequestHandeler:

    '''
        For the moment only does GET requests'''

    '''

    INITIALISATION method
        params: string                 : host_url : domain
        params: dict                   : args     : arguments to complete the url
        return: RequestHandeler_Object :          : client connecting to the server
    '''
    def __init__(self, host_url):
        self.host = host_url
        #self.args = args
        #self.url = self.prepare_request()
        #self.url = "http://ec.europa.eu/eurostat/wdds/rest/data/v2.1/json/en/ilc_pees01?precision=1&sex=T&yn_rskpov=NO_ARP&yn_rskpov=YES_ARP&unit=PC&workint=WI0-02&workint=WI02-1_NAP&lev_depr=NSEV&lev_depr=SEV&age=TOTAL"

        ## NB: not all possible responses for all methods are present in the status variable
        # However, all possible responses for GET requests should be present
        self.status = {
                    100 : ("Succesful response","[+] Connection accepted, cotinue with the request - ignore if the request already returned"),
                    102 : ("Succesful response","[*] Processing the request"),
                    200 : ("Succesful response","[+] OK! Data recieved"),
                    201 : ("Succesful response","[+] POST/PUT Request successful"),
                    202 : ("Succesful response","[*-] Warning: Non-autoritative information - response recieved but not complete"),
                    204 : ("Succesful response","[-] No Contenet: check the request"),
                    206 : ("Succesful response","[*-] Warning: Partial Contenent"),
                    208 : ("Succesful response","[*-] Warning: Milti-Status: multiple status code might be appropriate"),
                    301 : ("Redirection message","[-] Moved Permanently: the requested URL changed - new URL given in te response"),
                    302:  ("Redirection message","[-] Found: requested URL chenged temporaly"),
                    303 : ("Redirection message", "[-] See Other: do a GET request to another URL"),
                    400 : ("Client error","[-] Bad Request: check the request"),
                    401 : ("Client error","[-] Unauthorized: auhentification required"),
                    403 : ("Client error", "[-] Forbidden: no access rights to the contenets"),
                    404 : ("Client error", "[-] Not Found: the server can not fin the reqeusted resource - check the request"),
                    405 : ("Client error", "[-] Method Not Allowed: the request method you used has been deabled by the server - did you try a DELETE ?"),
                    406 : ("Client error","[-] Not Accepted: user-agents do not sayisfy the criteria"),
                    409 : ("Client error","[-] Conflict: request conflicts with the current state of the server"),
                    410 : ("Client error", "[-] Gone: resources no longer"),
                    411 : ("Client error", "[-] Length Required: Contnet-Length field required in the header"),
                    414 : ("Client error", "[-] URL Too Long: URL reuested longer than server can interpret"),
                    415 : ("Client error", "[-] Unsupported Media Type: the media information is not supported by the server"),
                    422 : ("Client error", "[-] Unprocesseble Entity"),
                    423 : ("Client error", "[-] Locked"),
                    428 : ("Client error", "[-] Upgrade Required: upgrade to a different protocol"),
                    429 : ('Client error', "[-] Too Many Requests: too many requests in a given amount of time"),
                    431 : ("Client error", "[-] Request Header Fields Too Large"),
                    500 : ("Server error", "[-] Internal Server Error: the server encontered an error that doen not know how to handle"),
                    501 : ("Server error", "[-] Not Implemented: the request method is not supported by the server"),
                    502 : ("Server error", "[-] Bad Gateway"),
                    503 : ("Server error", "[-] Service Unavailable: service not ready to handle the request"),
                    505 : ("Server error", "[-] HTTP Version Not Supported"),
                    511 : ("Server error", "[-] Network Autherntification Required: the clitns need top authenticate to gain network access")
        }


    '''
    Prepare the request
        params: RequestHandeler_Object
        return: string                 : url : full URL for the GET request
    '''
    def prepare_request(self):
        url = self.host + self.args['table'] + "?"
        for key in self.args:
            if key != 'table':
                if len(self.args[key].split(',')) > 1:
                    for item in self.args[key].split(','):
                        url += "%s=%s&" %(key, item)
                else:
                    url += "%s=%s&" %(key, self.args[key])
        return url[:-1]

    '''
    Do the get request
        params: RequestHandeler_Object
        return:  dict                  : data :    jason dict
        return : Response_Object       : response object with
                                            response data, status and GET url as attributes
    '''
    def get_request(self, args=None):
        if args != None:
            self.args = args
        self.url = self.prepare_request()
        r = requests.get(self.url)
        for key in self.status:
            if key == r.status_code:
                message = self.status[key][1]
                print(message)
                print("\t%s" % (self.status[key][0]))
                if '[-]' in message:
                    print('\tData not extracted successfully')
                    print('\ton the request %s' %(self.url))
                    return Response({'dict' : None , 'str' : None}, {r.status_code : message}, self.url)
                    #print('Exiting ...')
                    #sys.exit()
        # json dict
        datadict = json.loads(r.text)
        #jason string
        datastr = json.dumps(datadict, indent=4, sort_keys=True)
        data = {'dict': datadict, 'str' : datastr}

        return Response(data, {r.status_code : message}, self.url)

    '''
        Updates filters for the ger request

        params: RequestHandeler_Object
        params: list of str: opional arguments in the 'key = value' form
        return: void
    '''
    def update_args(self, *arg):
        args_dict = update_args_to_dict(arg)
        for key in args_dict:
            self.args[key] = args_dict[key]
        args_dict


class Response:

    def __init__(self, data, status, get_url):
        self.data = data
        self.status = status
        self.url = get_url

    def __str__(self):
        output = ''
        for key in self.__dict__:
            if type(self.__dict__[key]) == type({1:2}):
                output += '%s =>\n' % key
                if key == 'data':
                    output += "\t%s => %s - json-dictionary\n" % ('dict', type(self.__dict__[key]['dict']))
                    output += "\t%s => %s - json-string\n" % ('str', type(self.__dict__[key]['str']))
                elif key == 'status':
                    output += "\t%s => %s\n" % (list(self.__dict__[key].keys())[0], list(self.__dict__[key].values())[0])
            else:
                output += "%s => %s\n" % (key, self.__dict__[key])
        return output


'''
From separated arguments to dict
    params:  str :  table :    'key = value' form
    params:  str:   optonal args in the same form as previous
    return:  dict:  url_args:  arguments for the URL

'''
def args_to_dict(table, *args, **kwargs):
    url_args = {}
    url_args['table'] = table.split("=")[1].strip(' ')
    for ar in args:
        l = ar.split("=")
        url_args[l[0].strip(" ")] = l[1].strip(" ")
    return url_args

'''
From separated arguments to dict fixed argument list coming from RequestHandeler.update_args
    params:  list of str :  args :  'key = value' form
    return:  dict:  update_args:  dictionary of arguments to update
                                    - to update RequestHandeler.args attribute
'''
def update_args_to_dict(args):
    update_args = {}
    for ar in args:
        l = ar.split("=")
        update_args[l[0].strip(" ")] = l[1].strip(" ")
    return update_args


def args_to_dict_fun(table='', na_item='', precision='1', unit='', time='', sector=''):
    tmp = list(locals().keys())
    inputs = [table, na_item, precision, unit, time, sector]
    url_args = {}
    for i in range(len(tmp)):
        if inputs[i] != '':
            url_args[tmp[i]] = inputs[i]
    return url_args




def namestr(obj, namespace):
    #return [name for name in namespace if namespace[name] is obj]
    for name in namespace:
        if namespace[name] is obj:
            return name
